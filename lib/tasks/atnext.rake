include ActionView::Helpers::DateHelper
namespace :atnext do
  
  task :publish, [:source] => :environment do |t,args|
    time_start = Time.now
    #===================================================================
    # Create Video Object
    #===================================================================
    source    = args.source
    service = "Atnext"
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
    destination      = ENV_CONFIG['video_library'] + "/" + video.service  + "/" + video.category + "/" + Date.today.to_s #Override default output dir for ease access                    
    local_atnext_dir = Encoder::MP4(video, atnext_bitrates, destination, nil)  
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[#{service}] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")     
    
  end
  
end

task :atnext, [:source] => :environment do |t,args|
  source = args.source
  Rake::Task["atnext:publish"].invoke(source)
end
