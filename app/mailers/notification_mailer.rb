class NotificationMailer < ActionMailer::Base
  default :from => "hkjc.web.team@gmail.com"
  def akamai(video)
    @video = video
    mail(:to =>["work@marchi.me", "marchi.lau@gmail.com"], :subject => "[Akamai] #{@video.filename} - Ready")
  end
end
