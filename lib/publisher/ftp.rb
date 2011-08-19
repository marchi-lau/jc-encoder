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

           # Create Folder Tree
           system "curl --connect-timeout 20 --retry 20 -T '#{upload_txt}' --ftp-create-dirs -u #{ftp_username}:#{ftp_password} ftp://#{ftp_domain}#{destination}/upload.txt"
           
           # Upload Folder
           entries = Dir.entries(source)
           entries.delete(".")
           entries.delete("..")
           
           entries.each do |file|
             if File.directory?(file)
               destination = destination.chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ').chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ')
               break
             else
               destination = destination.chomp("/").slice(/.+\//).chomp("/").gsub(" ", '\\ ')
             end
           end
             
           system  "/usr/local/bin/ncftpput -v -R -u #{ftp_username} -p #{ftp_password} #{ftp_domain} #{destination} '#{source}'"
           Notifier::Status("[FTP] #{ftp_domain} - Done", "#{source}")     
           
           #Remove Dummy File
           FileUtils.rm_rf(upload_txt) 
          
        end
      end
    end
end