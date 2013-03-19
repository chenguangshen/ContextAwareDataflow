require 'rubygems'
require 'backports'
require 'narray'
require 'bud'

require_relative '../opportunistic_sampling/movement_detector_periodic'
require_relative '../opportunistic_sampling/place_sampler'

class SequenceBuilder
  def initialize(bud_instance, local_name)
    @bud_instance = bud_instance
    @local_name = local_name
    @seq = []
  end

  def instance; @bud_instance; end
  def sourceName(v); @sourceName = v; end
  def sinkName(v); @sinkName = v; end
  def into(v); @seq << v; end
  def wire(v); @seq << v; end
  def opts(v); @opts = v; end

  def build
    puts @seq.inspect
    @seq[0..-2].zip(@seq[1..-1]).each do |src, sink|
      puts src.inspect
      puts sink.inspect
      meth_name = "__bloom__#{@local_name}__#{sink.qualified_name}__#{src.qualified_name}"
      stmt = "#{sink.qualified_name}.#{@sinkName} <= #{src.qualified_name}.#{@sourceName}"
      @bud_instance.class.bloom_dynamic(meth_name, stmt)
    end
    nil
  end
end

# Our bloom code for wiring up sequential dataflow, 
# includes new "sugar" keyword that accepts a DSL block.
class SugarOpportunisticPlaceSampler
    include Bud

    build PlaceSampler => :placeSampler do; end
    build MovementDetector => :movementDetector do; end
    build MovementSampler => :movementSampler do; end

    state do
        periodic :timer, 1.0 # seconds
    end

    bloom do; 
        stdio <~ placeSampler.val
    end
  
    sugar SequenceBuilder => :namedSequence do
        sourceName 'val'
        sinkName 'trigger'
        
        wire timer
        into movementSampler
        into movementDetector
        into placeSampler
    end
end

if __FILE__ == $0
	h = SugarOpportunisticPlaceSampler.new
	h = h.run_fg
end