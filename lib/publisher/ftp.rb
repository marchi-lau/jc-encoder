module Publisher
  class << self
    def FTP(ftp_username, ftp_password, ftp_domain, source, destination)
      Publisher::FTP.upload(ftp_username, ftp_password, ftp_domain, source, destination)
    end
  end

    module FTP
      class << self
        def upload(ftp_username, ftp_password, ftp_domain, source, destination)
           upload_txt = "#{Rails.root.to_s}/lib/publisher/upload.txt"
           File.open(upload_txt, 'w') {|f| f.write("") }
           
           Notifier::Status("[FTP] #{ftp_domain} - Start", "#{source}")
           
           language = destination.split("/").last
           
           if language.include?("chi-") or language.include?("eng-") or language.include?("pth-") or language.include?("can-")
             destination = destination.chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ').chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ')
           elsif language.include?("chi") or language.include?("eng") or language.include?("pth") or language.include?("can")
             destination = destination.chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ')
             source      = source + "/#{language}"
           else
             destination = destination.chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ')
           end
           
           
           # Create Folder Tree
           # curl --connect-timeout 20 --retry 20 -T '/Users/Marchi/Sites/jc-encoder/lib/publisher/upload.txt' --ftp-create-dirs -u ftp-upload:hkjc1234 ftp://hkjc.upload.akamai.com/115935/mobile/brts/2046/20460101/upload.txt
           
           command = "curl --connect-timeout 20 --retry 20 -T '#{upload_txt}' --ftp-create-dirs -u #{ftp_username}:#{ftp_password} ftp://#{ftp_domain}#{destination}/upload.txt"
           puts command
           system command 
           #/usr/local/bin/ncftpput -v -R -u ftp-upload -p hkjc1234 hkjc.upload.akamai.com /115935/mobile/brts/2046/20460101 '/Volumes/Internal HD/Videos/Akamai/M3U8/brts/2046/20460101/01'
           
           command = "/usr/local/bin/ncftpput -v -R -u #{ftp_username} -p #{ftp_password} #{ftp_domain} #{destination} '#{source}'"
           puts command
           system command
           
           Notifier::Status("[FTP] #{ftp_domain} - Done", "#{source}")     
           
           #Remove Dummy File
           FileUtils.rm_rf(upload_txt)
        end
      end
    end
end