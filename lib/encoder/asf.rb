module Encoder
  class << self
    def ASF(video = nil, bitrate = 500)
      Encoder::ASF.encode(video, bitrate)
    end
  end

    module ASF
      class << self
        def encode(video = nil, bitrates = 500)
          video.export_type = self.to_s.split("::").last
          filename          = video.filename
          source            = video.source
          @languages         = video.languages
          bitrate_audio     = 32
          FileUtils.rm_rf(video.dir_output)
          FileUtils.mkdir_p(video.dir_output)
          
          @languages.each do |language|
            FileUtils.mkdir_p(video.dir_output(language))
          end
          #===================================================================
          # Encode Audio
          #===================================================================
          # Extra Original Audio Track
          
            @languages.each_with_index do |language, index|
              audio_raw = video.audio_track("wav")
              audio_wav = video.audio_track("wav", language)
              audio_wma = video.audio_track("wma", language)
              
              Notifier::Status("[Encode] WMA - #{language} - #{bitrate_audio}kbps - Start", "#{filename}")

              system "/usr/local/bin/mplayer '#{source}' -channels 4 -af format=s16le -ao pcm:fast:waveheader:file='#{audio_raw}' -vo null -vc null -novideo -quiet -nolirc"

              # Extract Audio Channels from Audio Track
              system "/usr/local/bin/sox '#{audio_raw}' '#{audio_wav}' remix #{index + 1}"

              # Encode Audio Track into AAC
              system "/usr/local/bin/ffmpeg -y -i '#{audio_wav}' '#{audio_wma}' -acodec wmav2 -ab #{bitrate_audio}000"
              
              
              FileUtils.rm_rf(audio_wav)
              FileUtils.rm_rf(audio_raw)
              
            end # each_with_index
            
            #===================================================================
            # Encode Video
            #===================================================================
         
          @languages.each do |language|
              bitrates.each do |bitrate|
              bitrate_audio    = 32
              bitrate_video    = bitrate - bitrate_audio
              file_output      = video.file_output(bitrate, "asf", language)

              puts "========================================================================"
              puts "Encoding with FFmpeg..."
              puts "========================================================================"
              Notifier::Status("[Encode] ASF - #{bitrate_video}kbps - Start", "#{filename}")              

              system "/usr/local/bin/ffmpeg -y -i '#{video.source}' -an -vcodec wmv2 -b #{bitrate_video}k -s 400x300 '#{file_output}'"
              Notifier::Status("[Encode] ASF - #{bitrate_video}kbps - Ready", "#{filename}")              

              end
            end
          return video.dir_output
        end
      end
    end
end