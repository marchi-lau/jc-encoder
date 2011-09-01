module Encoder
  class << self
    def MP4(options)
      Encoder::MP4.encode(options)
    end
  end

    module MP4
      class << self
        def encode(options)
                      video = options[:video]
                   bitrates = options[:bitrates]
             hdflash_domain = options[:hdflash_domain]
          video.export_type = self.to_s.split("::").last.to_s
          if options[:languages].nil?
            @languages        = video.languages
          else
            @languages        = options[:languages]
          end
          filename          = video.filename
          source            = video.source
          bitrate_audio     = 64
          
          destination       = video.dir_output
          
          FileUtils.mkdir_p(destination)            
          
          @languages.each do |language|
            FileUtils.mkdir_p(video.dir_output(language))
          end
       
          #===================================================================
          # Encode Audio
          #===================================================================
          # Extra Original Audio Track
      
          if @languages.size > 1 or  video.category == "replay-short" or video.category == "replay-full" or video.category == "brts" or video.category == "trackwork" # Force Mono Hack
            @languages.each_with_index do |language, index|
              audio_raw = video.audio_track("wav")
              audio_wav = video.audio_track("wav", language)
              audio_aac = video.audio_track("aac", language)
              
              #Ensure Old Files are removed
              FileUtils.rm(audio_raw, :force => true )
              FileUtils.rm(audio_wav, :force => true )
              FileUtils.rm(audio_aac, :force => true )
              
              Notifier::Status("[Encode] AAC - #{language} - #{bitrate_audio}kbps - Start", "#{filename}")

              system "/usr/local/bin/mplayer '#{source}' -channels 4 -af format=s16le -ao pcm:fast:waveheader:file='#{audio_raw}' -vo null -vc null -novideo -quiet -nolirc"

              # Extract Audio Channels from Audio Track
              system "/usr/local/bin/sox '#{audio_raw}' '#{audio_wav}' remix #{index + 1}"

              # Encode Audio Track into AAC
              system "/usr/local/bin/ffmpeg -y -i '#{audio_wav}' '#{audio_aac}' -ac 2 -ab #{bitrate_audio}"
              
              
              FileUtils.rm(audio_wav, :force => true )
              FileUtils.rm(audio_raw, :force => true )
              
            end # each_with_index
            
            else
              language = @languages.first               
              audio_raw = video.audio_track("wav", language)
              audio_aac = video.audio_track("aac", language)
              
              Notifier::Status("[Encode] AAC - #{language} - #{bitrate_audio}kbps - Start", "#{filename}")
              
              # Extract Original Audio
              system "/usr/local/bin/mplayer '#{source}' -channels 4 -af format=s16le -ao pcm:fast:waveheader:file='#{audio_raw}' -vo null -vc null -novideo -quiet -nolirc"
                                             
              # Encoded Audio Track into AAC
              system "/usr/local/bin/ffmpeg -y -i '#{audio_raw}' '#{audio_aac}' -ac 2 -ab #{bitrate_audio}"
              
              FileUtils.rm(audio_raw, :force => true )
                        
          end #IF languages.size > 1
          

          #===================================================================
          # Encode Video
          #===================================================================
          
            bitrates.each do |bitrate|
              video_mp4 = video.video_track(bitrate, "mp4")
              FileUtils.rm(video_mp4, :force => true) # Ensure old version is removed
              
              bitrate_video = bitrate - bitrate_audio
              Notifier::Status("[Encode] MP4 - #{bitrate_video}kbps - Start", "#{filename}")              
              
              vid_opts = 'ref=2:mixed-refs:bframes=6:b-pyramid=1:weightb=1:analyse=all:8x8dct=1:subme=7:me=umh:merange=24:filter=-2,-2:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto'
            
              job = HandBrake::CLI.new(:bin_path => "#{Rails.root.to_s}/bin/HandBrakeCLI", :trace => true).input("#{source}")
             job.verbose.markers.audio('none').deinterlace.encoder('x264').vb("#{bitrate}").x264opts(vid_opts).output("#{video_mp4}")
              
              Notifier::Status("[Encode] MP4 - #{bitrate_video}kbps - Ready", "#{filename}")
            end
            
          #===================================================================
          # Combine Audio Tracks & Video Tracks
          #===================================================================
          @languages.each do |language|
            bitrates.each do |bitrate|
              audio_track = video.audio_track("aac", language)
              video_track = video.video_track(bitrate, "mp4")
                output    = video.file_output(bitrate, "mp4", language)
                
               # Ensure old version is removed
               FileUtils.rm(destination, :force => true ) 
               FileUtils.rm(output, :force => true )   
              
              system "/usr/local/bin/mp4box -add '#{audio_track}' '#{video_track}' -out '#{output}'"
              
              FileUtils.mv(output, destination) if destination != video.dir_output
            end            
          end
          
          bitrates.each do |bitrate|
            video_track = video.video_track(bitrate, "mp4")
            FileUtils.rm(video_track, :force => true )
          end
          
          @languages.each do |language|
            audio_track = video.audio_track("aac", language)
            FileUtils.rm(audio_track, :force => true )
          end
          
          FileUtils.rm(video.dir_output) if destination != video.dir_output
          
          #===================================================================
          # Generate SMIL
          #===================================================================
          if !hdflash_domain.nil? # Ignore SMIL if no hdflash-domain
          
          @languages.each do |language|
           file_smil = video.file_smil(language)
                smil = Nokogiri::XML::Builder.new do |xml|                                              
               xml.doc.create_internal_subset(
                 'smil',
                 "-//W3C//DTD SMIL 2.0//EN",
                 "http://www.w3.org/TR/html4/loose.dtd"
               )
                   xml.smil(:xmlns => "http://www.w3.org/2001/SMIL20/Language") {
                     xml.head {
                       xml.meta(:name => "category", :content => video.category)
                       xml.meta(:name => "httpBase", :content => "http://" + hdflash_domain + "/")
                       xml.meta(:name => "rtmpAuthBase", :content => "hdflash_base_url")
                       xml.meta(:name => "vod", :content => "true")
                   }

                    xml.body {
                       xml.switch(:id => video.category) {
                         bitrates.each do |bitrate|
                           xml.video(:src => video.path_smil(bitrate, language), :"system-bitrate" => bitrate*1000)
                         end
                       }
                     }
                   }                                                                                                                                                                                 
                       end
            
              # Ensure old version is removed
              FileUtils.rm(file_smil, :force => true )
              File.open(file_smil, 'w') {|f| f.write(smil.to_xml) }
          end  
          end
            return destination
      end #Class encode 
      
      end
      
    end
end

