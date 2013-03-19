require 'rubygems'
require 'backports'
require 'bud'

require_relative 'sequencer'

module SequencePruner
  state do
  	interface input, :pruneBelow, [:key] => [:timestamp]
  	# table :sequence, [:timestamp] => [:sample]
  end

  bloom do
    sequence <- (pruneBelow * sequence).pairs do |p, s|
    	s if s.timestamp <= p.timestamp
   end
  end
end

if __FILE__ == $0
	class Main
	  include Bud
	  include Sequencer
	  include SequencePruner

	  bloom do
	  	stdio <~ sequence.inspected

	  end
	end

	h = Main.new
	h.register_callback(:pruneBelow) { |x| puts "----END_OF_TICK---" }
	h.run_bg
	h.sync_do { h.input_stream <+ [[123, 1, [6,7,8]], [545, 1, [0,1,2,3]]] }
	h.sync_do { h.pruneBelow <+ [['prune', 547]] }
	h.sync_do { h.pruneBelow <+ [['prune', 123]] }
	h.sync_do { h.input_stream <+ [[124, 1, [-1]]] }
	h.sync_do { h.input_stream <+ [[123, 1, [-3]]] }
	h.tick
end
