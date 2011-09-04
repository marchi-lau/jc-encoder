module Publisher
    module SSH
      class << self
        def rm_rf(ssh_key, domain, dir)
          command =  "ssh -y -i '#{ssh_key}' sshacs@#{domain} rm -rf '#{dir}'"
          puts command
          system command
        end
      end
    end
end