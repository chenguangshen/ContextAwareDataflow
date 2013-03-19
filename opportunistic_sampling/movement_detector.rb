require 'rubygems'
require 'backports'
require 'bud'
require 'narray'

require_relative 'movement_sampler'
require_relative 'sequencer'
require_relative 'segmenter'
require_relative 'segmenter_auto'

module MovementDetectorModule
  state do
    interface output, :movement, [:start, :movement]
    scratch :frame_stats, [:key, :start] => [:vals]
    scratch :frame_vars, [:key, :start] => [:stdev]
  end

  bloom do
    # Wire input of segmenter to output of sampler
    input_stream <= samples

    # Gather first-order statistics on each window
    frame_stats <= frames.map do |frame|
      [
        frame.key, frame.start,
        frame.vals.reduce({}) do |memo, v|
          memo['sum'] ||= 0
          memo['sum2'] ||= 0
          memo['size'] ||= 0
          memo['sum'] += v
          memo['sum2'] += v ** 2
          memo['size'] += 1.0
          memo
        end
      ]
    end

    # Compute stdev for each window
    frame_vars <=  frame_stats do |s| [
        s.key, s.start,
        Math.sqrt((s.vals['sum2'] / s.vals['size']) - \
        (s.vals['sum'] / s.vals['size']) ** 2)
      ] if s.vals.include?('size')
    end

    movement <= frame_vars do |f|
      [f.start, f.stdev] if f.stdev > 1.0
    end
  end
end

module MovementDetector
  include MovementSampler
  # import Sampler => :sampler
  include Sequencer
  include Segmenter
  include AutoSegmenter
  include MovementDetectorModule
end

if __FILE__ == $0
  class Main
    include Bud
    include MovementDetector

   bloom do
      # stdio <~ frame_vars { |s| ["stdev: #{s.stdev} @ t=#{s.start}"] }
      stdio <~ movement {|m| ["movement detected @ t=#{m.start}"]}
      stdio <~ frames.inspected
    end
  end

  h = Main.new
  h.run_bg
  h.register_callback(:frames) { |f| puts "----END_OF_TICK---" }
  h.sync_do { h.trigger <+ [['once', 0.0]] }
  h.sync_do { h.frame_specs <+ [['thrice_a_second', 333, 1000]] }
  h.sync_do { h.trigger <+ [['once', 1000.0]] }

  h.tick
  h.tick
end
