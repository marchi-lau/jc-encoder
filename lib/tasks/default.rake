  task :export, [:source] => :environment do |t, args|
    time_start = Time.now
    
    source    = args.source
    
    Rake::Task[:akamai].invoke(source)
    Rake::Task[:atnext].invoke(source) if source.include?("replay-full") or source.include?("brts")
    Rake::Task[:legacy].invoke(source) if source.include?("replay-full")
    Rake::Task[:archive].invoke(source)
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[All Tasks] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{source}")     
    
  end
    
  task :hosuekeep, [:source] => :environment do |t, args|
    time_start = Time.now
    
    source    = args.source    
#    Rake::Task[:akamai:housekeep].invoke
        
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[All Tasks] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{source}")     
    
  end
  
  task :archive, [:source] => :environment do |t, args|
    time_start = Time.now
    #===================================================================
    # Save Video to Database
    #===================================================================
    
    source  = args.source
    filename = File.basename(source,  File.extname(source))
    handbraking = HandBrake::CLI.new(:bin_path => "#{Rails.root.to_s}/bin/HandBrakeCLI", :trace => true).input("#{source}")
    titles = handbraking.scan
    duration = titles[1].seconds            # => "01:21:18"
    video = Video.create(:source => source, :filename => filename, :duration => duration)
    
    #===================================================================
    # Create Video Object
    #===================================================================
    service   = "Archive"
    video     = EncodingVideo.new(:source   => source, 
                                  :service  => service)
    
    Notifier::Status("Start Archving", "#{video.filename}")     
    
    #===================================================================
    # Video Quality
    #===================================================================

    archive_bitrates    = [5000]

    #===================================================================  
    # Encode
    # Encoder::MP4(VIDEO, [bitrates], destination)
    #===================================================================
    if (File.new(source).size / 1024**3) > 1                              
      local_archive_dir = Encoder::MP4(video, archive_bitrates)  
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
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("Archive Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")
  end