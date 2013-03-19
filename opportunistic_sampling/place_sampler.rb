require 'rubygems'
require 'backports'
require 'bud'
require 'narray'

require_relative 'sampler'

module PlaceSampler
  include Sampler

  def get_sample_buffer(ts)
    return {'rate' => 1.0, 'buffer' => ['SOMEWHERE_NOT_IN_BOELTER']}
  end

end