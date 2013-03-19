require 'rubygems'
require 'backports'
require 'bud'

require_relative '../opportunistic_sampling/movement_detector'
require_relative '../opportunistic_sampling/sequencer_prune'

module MovementDetectorTemp
	include MovementDetector
	include SequencePruner
end

class PeriodicMovementDetector
	include Bud
	import MovementDetectorTemp => :inner_detector

	state do
		periodic :timer, @sampleInterval
		interface output, :movement, [:start, :movement]
	end

	def initialize(windowSize, stride, sampleInterval, sampleGetter, ttl, opts = {})
	    @windowSize = windowSize
	    @stride = stride
	    @sampleInterval = sampleInterval
	    @sampleGetter = sampleGetter
		@ttl = ttl
				
	    class << self
        	define_method("get_sample_buffer") { |ts| return {'rate'=>1.0, 'buffer'=>[0,1,2]}}
      		# define_method("get_sample_buffer") { |ts| @sampleGetter.call(ts) }
    	end

    	super opts
  	end

	bootstrap do
		inner_detector.frame_specs <= [['#{@windowSize}sec_window_every_#{@stride}sec', @stride, @windowSize]]
	end

	bloom :timeBasedRules do
		inner_detector.trigger <= timer {|t| [t.key, (t.val.to_f() * 1000).to_i()]}
		inner_detector.pruneBelow <= timer { |t| [t.key, ((t.val.to_f() - @ttl) * 1000).to_i()] }
	end

	bloom :debugOutput do
		stdio <~ [[ "sequence_length: #{inner_detector.sequence.length}, " + \
			"full_frames: #{inner_detector.frames.length}, " + \
			"movement_detect_count: #{inner_detector.movement.length}" ]]

		stdio <~ movement.inspected
	end

	bloom :movementOutput do
		temp :movement_count <= inner_detector.movement.reduce({}) do |memo, m|
			memo['count'] ||= 0
			memo['count'] += 1
			memo
		end

		temp :latest_movement_time <= inner_detector.movement.group([], max(:start))

		movement <= (movement_count * latest_movement_time).pairs do |cnt, latest|
			[latest[0], cnt[0]['count']]
		end
	end
end

class PeriodicMovementDetectorBuilder
	def initialize(unsued_bud_instance, unused_local_name); end;  
	def windowSize(v); @windowSize = 1000 * v; end
	def stride(v); @stride = 1000 * v; end
	def sampleInterval(v); @sampleInterval = v; end
	def sampleGetter(&v); @sampleGetter = v; end
	def ttl(v); @ttl = v; end
	def opts(v); @opts = v; end

	def build
		PeriodicMovementDetector.new(@windowSize, @stride, @sampleInterval, @sampleGetter, @ttl, @opts)
	end
end

if __FILE__ == $0
	class Main
		include Bud
		include PeriodicMovementDetector
	end

	h = Main.new
	h.run_fg
end