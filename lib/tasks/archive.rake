task :archive, [:source] => :environment do |t, args|
  time_start = Time.now
  source  = args.source
  
  #===================================================================
  # Create Video Object
  #===================================================================
  service   = "Archive"
  video     = EncodingVideo.new(:source   => source, 
                                :service  => service)
  
  Notifier::Status("Start Archving", "#{video.filename}")     
  
  #===================================================================
  # Save Video to Database
  #===================================================================
  filename = File.basename(source,  File.extname(source))
  handbraking = HandBrake::CLI.new(:bin_path => "#{Rails.root.to_s}/bin/HandBrakeCLI", :trace => true).input("#{source}")
    titles = handbraking.scan
  duration = titles[1].seconds            # => "01:21:18"
  
  time_elapsed = distance_of_time_in_words(Time.now, time_start)
  if video.languages.size > 1
    video.languages.each do |language|
      Video.create(:source => source, :filename => "#{video.basename}_#{language}", :duration => duration)
    end
  else
      Video.create(:source => source, :filename => filename, :duration => duration)
  end
  
  Notifier::Status("Archive Complete. 
                    Time Elapsed: #{time_elapsed}", "#{video.filename}")
                    
  #===================================================================
  # Video Quality
  #===================================================================

  archive_bitrates    = [5000]

  #===================================================================  
  # Encode
  # Encoder::MP4(VIDEO, [bitrates], destination)
  #===================================================================
  if (File.new(source).size / 1024**3) > 1                              
    local_archive_dir = Encoder::MP4(:video => video, :bitrates => archive_bitrates)  
    FileUtils.rm(source)
  else
    video.export_type = ""
    FileUtils.mkdir_p(video.dir_output)
    FileUtils.mv(source, video.dir_output)
  end
  #===================================================================
  # Upload / Publish
  # Publisher::FTP(ftp_username, ftp_password, ftp_domain, source, destination)
  #===================================================================

 # FileUtils.rm(source)
  

end