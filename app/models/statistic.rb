class Statistic < ActiveRecord::Base
  after_initialize :init

  def init
    self.encoded_at  ||= Date.today           #will set the default value only if it's nil
    self.times ||= 0 #let's you set a default association
  end
  
end
