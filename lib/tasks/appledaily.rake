include ActionView::Helpers::DateHelper
namespace :appledaily do
  task :publish, [:source] => :environment do |t,args|
    time_start = Time.now
    #===================================================================
    # Create Video Object
    #===================================================================
    
    source    = args.source
    
    service = "AppleDaily"
    video     = EncodingVideo.new(:source    => source, 
                                  :service   => service)
                                  
    
    Notifier::Status("[#{service}] Start Publishing", "#{video.filename}")     

    #===================================================================
    # Video Quality
    #===================================================================

    atnext_bitrates    = [1200]

    #===================================================================  
    # Encode
    # Encoder::MP4(VIDEO, [bitrates])
    #===================================================================
    video.destination = ENV_CONFIG['video_library'] + "/" + video.service  + "/" + video.category + "/" + Date.today.to_s #Override default output dir for ease access                    
    
    local_atnext_dir = Encoder::MP4(:video => video, :bitrates => atnext_bitrates, :languages => ["chi"])  
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[#{service}] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")     
    
  end
  
end

task :appledaily, [:source] => :environment do |t,args|
  source = args.source
  if source.include?("replay-full") or source.include?("brts")
    Rake::Task["appledaily:publish"].invoke(source)
  else
    Notifier::Status("[AppleDaily] Bypass.", source)     
  end
  
end
