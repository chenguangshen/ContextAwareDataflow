require 'rubygems'
require 'backports'
require 'narray'
require 'bud'

require_relative 'SequenceSugarLib'

# Our bloom code for wiring up sequential dataflow, 
# includes new "sugar" keyword that accepts a DSL block.
class SugarOpportunisticPlaceSampler
    include Bud

    build TimerSugar => :triggerTimer do
        period 1.0
    end

    build MovementDetectorSugar => :movementDetector do
        windowSize 3.0    # configure window size
        stride 3.0        # configure stride for new sample
        ttl 10.0          # limit the number of frames
    end
    
    build PlaceSamplerSugar => :placeSampler do; end
    
    bloom do; 
        stdio <~ placeSampler.samples.inspected
    end
  
    sugar SequenceBuilder => :namedSequence do
        sourceName 'val'
        sinkName 'trigger'
        
        wire instance.triggerTimer
        into instance.movementDetector
        into instance.placeSampler
    end
end

if __FILE__ == $0
	h = SugarOpportunisticPlaceSampler.new
	h = h.run_fg
end