require 'rubygems'
require 'backports'
require 'bud'

require_relative '../opportunistic_sampling/movement_detector'
require_relative '../opportunistic_sampling/sequencer_prune'

module MovementDetectorTemp
	include MovementDetector
	include SequencePruner
end

module PeriodicMovementDetector
	import MovementDetectorTemp => :inner_detector

	state do
		periodic :timer, 1.0
		interface output, :movement, [:start, :movement]
	end

	bootstrap do
		inner_detector.frame_specs <= [['3sec_window_every_1sec', 1000, 3000]]
	end

	bloom :timeBasedRules do
		inner_detector.trigger <= timer {|t| [t.key, (t.val.to_f() * 1000).to_i()]}
		inner_detector.pruneBelow <= timer { |t| [t.key, ((t.val.to_f() - 10) * 1000).to_i()] }
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

if __FILE__ == $0
	class Main
		include Bud
		include PeriodicMovementDetector
	end

	h = Main.new
	h.run_fg
end