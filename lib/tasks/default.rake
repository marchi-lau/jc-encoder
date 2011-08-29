require 'open-uri'
require 'net/http'
  task :export, [:source] => :environment do |t, args|
    time_start = Time.now
    
    source    = args.source
    
    Rake::Task[:akamai].invoke(source)
    Rake::Task[:appledaily].invoke(source)
    Rake::Task[:legacy].invoke(source)
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
