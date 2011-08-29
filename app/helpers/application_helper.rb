module ApplicationHelper
  def convert_seconds_to_time(seconds)
     total_minutes = seconds / 1.minutes
     seconds_in_last_minute = seconds - total_minutes.minutes.seconds
     "#{total_minutes}m #{seconds_in_last_minute}s"
  end
end
