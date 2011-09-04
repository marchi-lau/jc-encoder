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
  
end
