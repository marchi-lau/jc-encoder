module Encoder
  class << self
    def ASF(source = nil, destination = nil, bitrate = 1200)
      Encoder::ASF.encode(source, destination, bitrate = 1200 )
    end
  end

    module ASF
      class << self
        def encode(source = nil, destination = nil, bitrates = [700,1200])
          
        end
      end
    end
end