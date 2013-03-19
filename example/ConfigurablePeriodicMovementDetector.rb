require 'rubygems'
require 'backports'
require 'bud'

require_relative 'PeriodicMovementDetectorTemplate'

class ConfigurablePeriodicMovementDetector
	include Bud

	build PeriodicMovementDetectorBuilder => :detector do
		sampleInterval 1.0	# configure sampling period
		windowSize 3.0		# configure window size
		stride 1.0			# configure stride for new sample
		ttl 10.0			# limit the number of frames
	end

	bloom do
		stdio <~ detector.movement.inspected
	end
end

if __FILE__ == $0
	h = ConfigurablePeriodicMovementDetector.new
	h.run_fg
end