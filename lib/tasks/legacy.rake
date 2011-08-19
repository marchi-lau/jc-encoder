include ActionView::Helpers::DateHelper
namespace :legacy do
  
  task :publish, [:source] => :environment do |t,args|
    time_start = Time.now
    #===================================================================
    # Create Video Object
    #===================================================================
    
    source    = args.source
    video     = EncodingVideo.new(:source    => source, 
                                  :service   => "Legacy")
    
    Notifier::Status("[Legacy] Start Publishing", "#{video.filename}")     
    #===================================================================
    # Video Quality
    #===================================================================

    legacy_bitrates    = [800]
    
    #===================================================================  
    # Encode
    # Encoder::MP4(VIDEO, destination, [bitrates])
    #===================================================================
    video.destination = ENV_CONFIG['video_library'] + "/" + video.service  + "/" + Date.today.to_s#Override default output dir for ease access                    
    local_legacy_dir  = Encoder::MP4(:video => video, :bitrates => legacy_bitrates)  
  
   
    #===================================================================
    # Upload / Publish
    # Publisher::FTP(ftp_username, ftp_password, ftp_domain, source, destination)
    #===================================================================

    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[Legacy] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")     
    
  end

end

task :legacy, [:source] => :environment do |t,args|
  source = args.source
  Rake::Task["legacy:publish"].invoke(source) if source.include?("replay-full")
end
