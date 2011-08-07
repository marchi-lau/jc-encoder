module Encoder
  class << self
    def M3U8(video = nil, bitrates = [700], http_domain = nil)
      Encoder::M3U8.segment(video, bitrates, http_domain)
      
    end
  end

    module M3U8
      class << self
        def segment(video = nil, bitrates = [700], http_domain = nil)
          video.export_type = self.to_s.split("::").last
          
          languages = video.languages
          filename  = video.filename
          source    = video.source
          bitrate   = bitrates.first #No VBR
          
          Notifier::Status("[Encode] M3U8 - Start", "#{video.filename}")  
               
            FileUtils.rm_rf(video.dir_output)
            FileUtils.mkdir_p(video.dir_output)

           languages.each do |language|
              FileUtils.mkdir_p(video.dir_output(language)) 
              file_output = video.file_output(bitrate, "mp4", language).gsub("M3U8", "MP4")
              dir_output  = video.dir_output(language)
              http_url    = "http://" + http_domain + "/mobile" + video.path(language)
          
              system "mediafilesegmenter '#{file_output}' -f '#{dir_output}' -t 10 -b  '#{http_url}' -B '#{filename}' -i '#{filename}.m3u8'"
              Notifier::Status("[Encode] M3U8 - Ready", "#{filename}")     
            end
            return video.dir_output
          end
      end
    end
end