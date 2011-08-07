include ActionView::Helpers::DateHelper
namespace :akamai do
  
  task :publish, [:source] => :environment do |t,args|
    time_start = Time.now
    #===================================================================
    # Create Video Object
    #===================================================================
    source    = args.source
    video     = EncodingVideo.new(:source    => source, 
                                  :service   => "Akamai")
    
    Notifier::Status("[Akamai] Start Publishing", "#{video.filename}")     
    
    #===================================================================
    # Publish Configuration
    #===================================================================
    
    cp_code             = 115935
    
    service             = "Akamai"
    hdflash_domain      = "hkjc-f.akamaihd.net"
    http_domain         = "streaming.hkjc.edgesuite.net"

    ftp_domain          = "hkjc.upload.akamai.com"
    ftp_username        = "ftp-upload"
    ftp_password        = "hkjc1234"
    
    #===================================================================
    # Video Quality
    #===================================================================

    hdflash_bitrates    = [700, 1200]
    m3u8_bitrates       = [700]
    threegp_bitrates    = [500]

    #===================================================================
    # Remote Path Setup
    #===================================================================
    
    netstorage_hdflash_dir     = File.join("/#{cp_code}/hdflash", video.path)
    netstorage_mobile_dir      = File.join("/#{cp_code}/mobile", video.path)
    
    #===================================================================  
    # Encode
    # Encoder::MP4(VIDEO, destination, [bitrates])
    #===================================================================
                                   
    local_hdflash_dir = Encoder::MP4(video, hdflash_bitrates, hdflash_domain)  
    local_mobile_dir  = Encoder::M3U8(video, m3u8_bitrates, http_domain) 
    #Encoder::3GP(3gp_bitrates, video, local_mobile_dir)
   
    #===================================================================
    # Upload / Publish
    # Uploader::FTP(ftp_username, ftp_password, ftp_domain, source, destination)
    #===================================================================

    Uploader::FTP(ftp_username, ftp_password, ftp_domain, local_hdflash_dir, netstorage_hdflash_dir)
    Uploader::FTP(ftp_username, ftp_password, ftp_domain, local_mobile_dir, netstorage_mobile_dir)
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    Notifier::Status("[Akamai] Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")     
    
  end
  
  task :housekeep do
    
  end
  
end

task :akamai, [:source] => :environment do |t,args|
  source = args.source
  Rake::Task["akamai:publish"].invoke(source)
end
