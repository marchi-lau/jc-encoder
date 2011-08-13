include ActionView::Helpers::DateHelper
namespace :atnext do
  
  task :publish, [:source] => :environment do |t,args|
    time_start = Time.now
    #===================================================================
    # Create Video Object
    #===================================================================
    source    = args.source
    video     = EncodingVideo.new(:source    => source, 
                                  :service   => "Akamai")
    
    Notifier::Status("[Atnext] Start Publishing", "#{video.filename}")     
    
    #===================================================================
    # Publish Configuration
    #===================================================================

    # No Remote Publish    
    
    #===================================================================
    # Video Quality
    #===================================================================

    atnext_bitrates    = [1200]

    #===================================================================
    # Remote Path Setup
    #===================================================================
    
    # No Remote Publish
    
    #===================================================================  
    # Encode
    # Encoder::MP4(VIDEO, destination, [bitrates])
    #===================================================================
                                   
    local_atnext_dir = Encoder::MP4(video, atnext_bitrates)  
    #Encoder::3GP(3gp_bitrates, video, local_mobile_dir)
   
    #===================================================================
    # Upload / Publish
    # Publisher::FTP(ftp_username, ftp_password, ftp_domain, source, destination)
    #===================================================================

    # No Remote Publish
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[Atnext] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")     
    
  end
  
end

task :atnext, [:source] => :environment do |t,args|
  source = args.source
  Rake::Task["atnext:publish"].invoke(source)
end
