require 'rubygems'
require 'backports'
require 'bud'
require 'narray'

require_relative 'sampler'

module MovementSampler
  include Sampler

  def get_sample_buffer(ts)
    std_dev = (NArray.sfloat(1).randomn! / 3.0) + 0.6
    # std_dev =  1.5
    # puts "StdDev of sample : #{std_dev.to_a()}"
    buffer = NArray.sfloat(33).randomn! * std_dev
    return {'rate' => (1.0/33.0)*1000.0, 'buffer' => buffer.to_a()}
  end

end