require 'rubygems'
require 'backports'
require 'bud'

module Sequencer
  state do
  	interface input, :input_stream, [:timestamp] => [:rate, :buffer]
  	table :sequence, [:timestamp] => [:sample]
  end

  bloom do
    sequence <+- input_stream.flat_map do |x|
      x.buffer.each_with_index.map do |s, ii|
      	[x.timestamp + (x.rate * ii), s]
      end
    end
  end
end

if __FILE__ == $0
	class Main
	  include Bud
	  include Sequencer
	  bloom do
	  	stdio <~ sequence.inspected
	  end
	end

	h = Main.new(:dump_rewrite)
	h.register_callback(:sequence) { |x| puts "----END_OF_TICK---" }
	h.run_bg
	h.sync_do { h.input_stream <+ [[123, 1, [6,7,8]], [545, 1, [0,1,2,3]]] }
	h.sync_do { h.input_stream <+ [[234, 0.5, [21,51,31]]] }
	h.sync_do { h.input_stream <+ [[234, 1, [0,0,0]]] }
	h.tick
end
