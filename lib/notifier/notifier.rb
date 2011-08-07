require 'ruby-growl'
module Notifier
  class << self
    def Status(message, body)
      #Notifier::Email.send()
      Growl.send(message, body)
    end
    
    def Alert(message, body)
      #Notifier::Email.send()
      Growl.send(message, body)
    end
  end

    module Email
      class << self
      end
    end
end

  class << Growl
    def send(message, body)
      @receipients = Growl.list 
      @receipients.each do |receipient|
        begin
          g = Growl.new receipient, "JC Encoder", ["Notification"]
          g.notify "Notification", message, body
        rescue
          puts "Growl Error."
        end
      end
    end 
  end