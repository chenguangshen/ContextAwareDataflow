require 'rubygems'
require 'backports'
require 'bud'
require 'narray'

module Sampler
  state do
  	interface input, :trigger, [:key] => [:timestamp]
  	interface output, :samples, [:timestamp] => [:rate, :buffer]
  end

  bloom do
  	samples <+ trigger do |t|
  		result = get_sample_buffer(t.timestamp)
  		[t.timestamp, result['rate'], result['buffer']]
  	end
  end
end

if __FILE__ == $0
	class Main
	  include Bud
	  include Sampler
	  bloom do
	  	stdio <~ samples.inspected
	  end

	  # def get_sample_buffer(ts)
	  # 	return {
	  # 		'rate' => 1, 
	  # 		'buffer' => ['s', 'o', 'm', 'e', 's', 't', 'u', 'f', 'f']
	  # 		}
	  # end

	  def get_sample_buffer(ts)
    	std_dev = NArray.sfloat(1).randomn!
    	buffer = NArray.sfloat(5).randomn! * std_dev
  	  	return { 'rate' => (1.0/5.0), 'buffer' => buffer.to_a() }
  	  end
	end

	h = Main.new
	h.run_bg
	h.sync_do { h.trigger <+ [['some_stream', 100]] }
	h.sync_do { h.trigger <+ [['some_stream', 200]] }
	h.tick
end
