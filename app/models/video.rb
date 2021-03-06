class Video < ActiveRecord::Base  
  
  attr_accessor :source
  
  # ================================================================================================
  # Statemachine
  # ================================================================================================
  state_machine :state, :initial => :online do
    event :publish do
      transition any => :online
    end
    event :unpublish do
      transition any => :offline
    end
  end
  # ================================================================================================
  # Scope
  # ================================================================================================
  
  # ================================================================================================
  # Video URL
  # ================================================================================================

  def smil
    File.join("http://streaming.hkjc.edgesuite.net","/hdflash", "#{self.path}/#{self.filename}.smil")
  end
  
  def m3u8
    File.join("http://iphone.hkjc.edgesuite.net", "/mobile", "#{self.path}/#{self.filename}.m3u8")
  end
  
  def mp4(bitrate)
    File.join("http://streaming.hkjc.edgesuite.net","/hdflash", "/#{self.path}/#{self.filename}_#{bitrate}kbps.mp4")
  end
  
  def url
    "http://#{ENV_CONFIG['web_server']}/videos/#{self.id}"
  end
  
  def playback_url
    "http://racing.hkjc.com/racing/video/play.asp?type=#{self.category}&date=#{self.title}&no=#{self.episode}&lang=#{self.language}"
  end
  
  def upload_txt
    File.join("http://streaming.hkjc.edgesuite.net", "/hdflash",  "#{self.path}/upload.txt")
  end
  
  # ================================================================================================
  # Video Name Attributes
  # ================================================================================================
  def path(language = self.language)
    case self.format
      when 3 then
        video_path = "/#{self.category}/#{self.year}/#{self.title}/#{self.episode}/#{language}" #replay-full_20110101_01_eng
      when 2 then
        video_path = "/#{self.category}/#{self.year}/#{self.title}/#{self.episode}" #trackwork_20110101_01
      when 1 then
        video_path = "/#{self.category}/#{self.title}" #pp_p101
    end
  end

  def basename
    splits = self.filename.split("_")
    splits.delete_at(3)
    return splits.join("_")
  end
  
  def format
    self.filename.count("_")
  end
  
  def category
    self.filename.split("_").first
  end

  def year
    begin
    self.filename.split("_")[1][0,4]
      rescue
    Time.year
    end
  end
  
  def title
    self.filename.split("_")[1]
  end
  
  def episode
    self.filename.split("_")[2]
  end
  
  def language
    case format
    when 3 then
      if self.languages.size > 1
        self.languages * "-"
      else
        self.filename.split("_")[3]
      end
        
      else
    "monolingual"
    end
    
  end
  
  def languages
    case format
    when 3 then
      self.filename.split("_")[3].split("-") 
    else
      ["monolingual"]
    end
  end
  
end
