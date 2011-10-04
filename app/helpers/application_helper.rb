require 'open-uri'
module ApplicationHelper
  def convert_seconds_to_time(seconds)
     total_minutes = seconds / 1.minutes
     seconds_in_last_minute = seconds - total_minutes.minutes.seconds
     "#{total_minutes}m #{seconds_in_last_minute}s"
  end
  def to_minutes(seconds)

  m = (seconds/60).floor
  s = (seconds - (m * 60)).round

  # return formatted time
  return "%02d:%02d" % [ m, s ]
  end
  
  def qrcode(url)

 
    matches = url.scan(/((http|https):\/\/(\&|\=|\_|\?|\w|\.|\d|\/|-)+(:\d+(\&|\=|\?|\w|\.|\d|\/|-)+)?)/)
    Bitly.use_api_version_3

    bitly = Bitly.new("marchilau", "R_98647d4a67b1690586bffa826974aa0b")

    for i in 0..matches.length
      if matches[i].to_s.size > 0
        logger.info("url " + matches[i][0])
        if matches[i][0].include? "bit.ly"
          logger.info("already a bitly url " + matches[i][0])
        else
          u = bitly.shorten(matches[i][0])
          url[matches[i][0]] = u.short_url
        end
      end
    end
    bitly_url = url
    
    image_tag "https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=#{bitly_url}&choe=UTF-8"
  end
  
  
end
