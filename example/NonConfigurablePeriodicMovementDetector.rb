require 'rubygems'
require 'backports'
require 'bud'

require_relative 'PeriodicMovementDetector'

module NonConfigurablePeriodicMovementDetector
	import PeriodicMovementDetector => :detector
	bloom do
		stdio <~ detector.movement.inspected
	end
end

if __FILE__ == $0
	class Main
		include Bud
		include NonConfigurablePeriodicMovementDetector
	end

	h = Main.new
	h.run_fg
end