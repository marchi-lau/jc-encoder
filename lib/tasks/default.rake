require 'open-uri'
require 'net/http'
  task :export, [:source] => :environment do |t, args|
    time_start = Time.now
    @statistic = Statistic.find_or_create_by_encoded_at(Date.today)
    source     = args.source
    
    # Automount NAS Volume
    username    = ENV_CONFIG['nas_user']
    password    = ENV_CONFIG['nas_password']
    nas_server  = ENV_CONFIG['nas_server']
    nas_share   = ENV_CONFIG['nas_share']
    video_library   = ENV_CONFIG['video_library']
    if !File.exists?(video_library)
      system "mkdir #{video_library}"
      system "mount_afp afp://#{username}:#{password}@#{nas_server}/#{nas_share} #{video_library}"
    end
    
    Rake::Task[:akamai].invoke(source)
    Rake::Task[:appledaily].invoke(source)
    Rake::Task[:legacy].invoke(source)
    Rake::Task[:archive].invoke(source)
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)    
    @statistic.times = @statistic.times + 1
    @statistic.save
    
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
  
  task :check, :needs => :environment do
    videos = Video.all
    videos.each do |video|
    url = URI.parse(video.smil)
    Net::HTTP.start(url.host, url.port) do |http|
      if http.head(url.request_uri).code == "404"
        puts "Offline      " + video.filename
        video.unpublish!
        
      else
        puts "Online        " + video.filename
        video.publish!
        
      end
    end
    end
  end

  task :remove, [:source] => :environment do |t,args|


  end