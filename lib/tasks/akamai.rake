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
    hdflash_domain      = AKAMAI_CONFIG['hdflash_domain']
    http_domain         = AKAMAI_CONFIG['http_domain']
    ftp_domain          = AKAMAI_CONFIG['netstorage_domain']
    ftp_username        = AKAMAI_CONFIG['ftp_username']
    ftp_password        = AKAMAI_CONFIG['ftp_password']
    
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
    netstorage_mobileweb_dir   = File.join("/#{cp_code}/3gp", video.path)
    
    #===================================================================  
    # Encode
    # Encoder::MP4(VIDEO, destination, [bitrates])
    #===================================================================
    local_hdflash_dir   = Encoder::MP4(:video => video, 
                                       :bitrates => hdflash_bitrates, 
                                       :hdflash_domain => hdflash_domain)  
                                       
    local_mobile_dir    = Encoder::M3U8(:video => video, 
                                        :bitrates => m3u8_bitrates, 
                                        :http_domain => http_domain) 
                                        
    #local_mobileweb_dir = Encoder::3GP(video, threegp_bitrates)
   
    #===================================================================
    # Upload / Publish
    # Publisher::FTP(ftp_username, ftp_password, ftp_domain, source, destination)
    #===================================================================
    
    Publisher::FTP(ftp_username, ftp_password, ftp_domain, local_hdflash_dir, netstorage_hdflash_dir)
    Publisher::FTP(ftp_username, ftp_password, ftp_domain, local_mobile_dir, netstorage_mobile_dir)
    #Publisher::FTP(ftp_username, ftp_password, ftp_domain, local_mobileweb_dir, netstorage_mobileweb_dir)
    
    time_elapsed = distance_of_time_in_words(Time.now, time_start)
    system "afplay /System/Library/Sounds/Glass.aiff"
    Notifier::Status("[Akamai] Publish Complete. 
                      Time Elapsed: #{time_elapsed}", "#{video.filename}")     

  end
  
  task :housekeep do
    time_start = Time.now
    #===================================================================
    # Create Video Object
    #===================================================================
    source    = args.source
    video     = EncodingVideo.new(:source    => source, 
                                  :service   => "Akamai")
    
    Notifier::Status("[Akamai] Start Publishing", "#{video.filename}")
    ftp_domain  = AKAMAI_CONFIG['netstorage_domain']
        cp_code = 115935
        ssh_key = AKAMAI_CONFIG['ssh_key']
        
    netstorage_hdflash_dir     = File.join("/#{cp_code}/hdflash", video.path)
    netstorage_mobile_dir      = File.join("/#{cp_code}/mobile", video.path)
    netstorage_mobile_dir      = File.join("/#{cp_code}/mobileweb", video.path)
    Publisher::SSH.offline(ssh_key, ftp_domain, netstorage_hdflash_dir)
    
    Notifier::Status("[Akamai] Housekeep Complete. 
                    Time Elapsed: #{time_elapsed}", "#{expired_videos.count} Videos Offline.")
    
  end
  
end

task :akamai, [:source] => :environment do |t,args|
  source = args.source
  Rake::Task["akamai:publish"].invoke(source)
end
