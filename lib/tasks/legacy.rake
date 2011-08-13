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
    # Encode
    # Encoder::MP4(VIDEO, destination, [bitrates])
    #===================================================================
    asf_bitrates    = [500]
                                   
    local_legacy_dir = Encoder::ASF(video, asf_bitrates)  
   
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
  Rake::Task["legacy:publish"].invoke(source)
end
