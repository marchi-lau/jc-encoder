class EncodingVideo < Video
  attr_accessor :source, :service, :export_type, :destination
  
  def dir_output(language = nil)
    if language.nil? && self.destination.nil?
      case self.format
        when 3 then
          ENV_CONFIG['video_library'] + "/" + self.service  + "/" + self.export_type + self.path.chomp("/").slice(/.+\//).chomp("/") 
        else
          ENV_CONFIG['video_library'] + "/" + self.service  + "/" + self.export_type + self.path.chomp("/")
        end
      
    elsif !language.nil? && self.destination.nil?
        if self.format == 3 && self.languages.size > 1
         ENV_CONFIG['video_library'] + "/"  + self.service  + "/" + self.export_type.to_s + self.path.chomp("/").slice(/.+\//).chomp("/") + "/" + language # To be moved to YAML
        else
         ENV_CONFIG['video_library'] + "/" + self.service  + "/" + self.export_type.to_s + self.path.chomp("/")
        end
    
    elsif language.nil? && !self.destination.nil?
        destination
    elsif !language.nil? && !self.destination.nil?
        destination + "/" + language 
     end
  end

  def prefix(language = nil)      
    self.dir_output(language) + "/" + self.basename
  end
  
  def audio_track(format, language = nil)
      self.prefix(language) + "_#{language}.#{format}"
  end
  
  def video_track(bitrate, format)
    self.prefix + "_#{bitrate}kbps_video.#{format}"
  end
  
  def file_output(bitrate, format, language = nil)
    case self.format
    when 3 then
      self.prefix(language) + "_#{language}_#{bitrate}kbps.#{format}"
    else
      self.prefix(language) + "_#{bitrate}kbps.#{format}"
    end
      
  end
  
  def file_smil(language = nil)
    case self.format
    when 3 then
      self.prefix(language) + "_#{language}.smil"
    else
      self.prefix(language) + ".smil"
    end
      
  end
  
  def file_m3u8(language = nil)
 
    case self.format
    when 3 then
      self.basename + "_#{language}.m3u8"
    else
      self.basename + ".m3u8"
    end
  end
  
  def path_smil(bitrate, language = nil)
    case self.format
    when 3 then
      "#{self.path(language)}/#{self.basename}_#{language}_#{bitrate}kbps.mp4"[1..-1]
    else
      "#{self.path}/#{self.basename}_#{bitrate}kbps.mp4"[1..-1]
    end
  end
  
  # Override Filename from Source
  def filename
     File.basename(self.source,  File.extname(self.source))
  end
  
end