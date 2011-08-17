module Encoder
  class << self
    def M3U8(video = nil, bitrates = [700], http_domain = nil, destination = nil)
      Encoder::M3U8.segment(video, bitrates, http_domain, destination)
      
    end
  end

    module M3U8
      class << self
        def segment(video = nil, bitrates = [700], http_domain = nil, destination = nil)
          video.export_type = self.to_s.split("::").last
          
          languages = video.languages
          filename  = video.filename
          source    = video.source
          bitrate   = bitrates.first #No VBR
          destination = video.dir_output if destination.nil?
          
          Notifier::Status("[Encode] M3U8 - Start", "#{video.filename}")  
               
            FileUtils.rm_rf(destination)
            FileUtils.mkdir_p(destination)

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