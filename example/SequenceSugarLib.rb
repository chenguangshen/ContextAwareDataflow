require 'rubygems'
require 'backports'
require 'narray'
require 'bud'

require_relative '../opportunistic_sampling/sampler'
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
    # periodic :timer, @sampleInterval
    interface input, :trigger
    interface output, :val, [:start, :movement]
  end

  def initialize(windowSize, stride, sampleGetter, ttl, opts = {})
      @windowSize = windowSize
      @stride = stride
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
    inner_detector.trigger <= trigger {|t| [t.key, (t.val.to_f() * 1000).to_i()]}
    inner_detector.pruneBelow <= trigger { |t| [t.key, ((t.val.to_f() - @ttl) * 1000).to_i()] }
  end

  bloom :debugOutput do
    stdio <~ [[ "sequence_length: #{inner_detector.sequence.length}, " + \
      "full_frames: #{inner_detector.frames.length}, " + \
      "movement_detect_count: #{inner_detector.movement.length}" ]]

    stdio <~ val.inspected
  end

  bloom :movementOutput do
    temp :movement_count <= inner_detector.movement.reduce({}) do |memo, m|
      memo['count'] ||= 0
      memo['count'] += 1
      memo
    end

    temp :latest_movement_time <= inner_detector.movement.group([], max(:start))

    val <= (movement_count * latest_movement_time).pairs do |cnt, latest|
      [latest[0], cnt[0]['count']]
    end
  end
end

class MovementDetectorSugar
  def initialize(unsued_bud_instance, unused_local_name); end;  
  def windowSize(v); @windowSize = 1000 * v; end
  def stride(v); @stride = 1000 * v; end
  def sampleGetter(&v); @sampleGetter = v; end
  def ttl(v); @ttl = v; end
  def opts(v); @opts = v; end

  def build
    PeriodicMovementDetector.new(@windowSize, @stride, @sampleGetter, @ttl, @opts)
  end
end

class PlaceSampler
    include Bud
    include Sampler

    def initialize(opts = {})
        super opts
    end

    def get_sample_buffer(ts)
      return {'rate' => 1.0, 'buffer' => ['SOMEWHERE_NOT_IN_BOELTER']}
    end
end

class PlaceSamplerSugar
    def initialize(u, v); end
    def opts(v); @opts = v; end

    def build
      PlaceSampler.new(@opts)
    end
end

class Timer
    include Bud

    def initialize(period, opts = {})
        @period = period
        super opts
    end

    state do
        periodic :timer, @period # seconds
        interface output, :val  
    end

    bloom do
        val <= timer
    end
end

class TimerSugar
    def initialize(u, v); end
    def period(v); @period = v; end
    def opts(v); @opts = v; end

    def build
      Timer.new(@period, @opts)
    end
end

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
        # puts @seq.inspect
        @seq[0..-2].zip(@seq[1..-1]).each do |src, sink|
            # puts src.inspect
            # puts sink.inspect
            meth_name = "__bloom__#{@local_name}__#{sink.qualified_name}__#{src.qualified_name}"
            stmt = "#{sink.qualified_name}.#{@sinkName} <= #{src.qualified_name}.#{@sourceName}"
            # puts stmt
            @bud_instance.class.bloom_dynamic(meth_name, stmt)
        end
        nil
    end
end