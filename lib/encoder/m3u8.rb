module Encoder
  class << self
    def M3U8(options)
      Encoder::M3U8.segment(options)
    end
  end

    module M3U8
      class << self
        def segment(options)
          
          
                      video = options[:video]
                   bitrate = options[:bitrates].first  #No VBR
                http_domain = options[:http_domain]
                
                
                languages   = options[:languages]
                languages   = video.languages if languages.nil?
                
          
                  filename  = video.filename
                  source    = video.source
          video.export_type = self.to_s.split("::").last
          destination = options[:destination]
          
          destination = video.dir_output if destination.nil?
          

               
            FileUtils.rm_rf(destination)
            FileUtils.mkdir_p(destination)
            Notifier::Status("[Encode] M3U8 - Start", "#{video.filename}")  

           languages.each do |language|
             
              if destination.nil?
                dir_output = video.dir_output(language)
              else
                dir_output = destination + "/" + language
              end
              
              FileUtils.mkdir_p(dir_output) 
              file_output = video.file_output(bitrate, "mp4", language).gsub("M3U8", "MP4")
              http_url    = "http://" + http_domain + "/mobile" + video.path(language)
          
              system "mediafilesegmenter '#{file_output}' -f '#{dir_output}' -t 10 -b  '#{http_url}' -B '#{filename}' -i '#{filename}.m3u8'"
              Notifier::Status("[Encode] M3U8 - Ready", "#{filename}")     
            end
            return destination
          end
      end
    end
end