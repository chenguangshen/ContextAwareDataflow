require 'rubygems'
require 'backports'
require 'bud'
require 'narray'

require_relative 'movement_detector_periodic'
require_relative 'place_sampler'


# Simplified sampler, samples whenever there is movement
#  - a more sophisticated sampler would have a refresh
#    interval so that location is not polled excessively!
module OpportunisticPlaceSampler
  import PlaceSampler => :placeSampler
  import PeriodicMovementDetector => :mvt_detector

  state do
  end

  bloom do
  	placeSampler.trigger <= mvt_detector.movement { |m| [m.start.to_s, m.start] }
  end

  bloom do
  	stdio <~ placeSampler.samples.inspected
  end
end

if __FILE__ == $0
	class Main
		include Bud
		include OpportunisticPlaceSampler
	end

	h = Main.new
	h = h.run_fg
end