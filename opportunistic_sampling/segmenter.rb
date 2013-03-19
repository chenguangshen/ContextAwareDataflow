require 'rubygems'
require 'backports'
require 'bud'

require_relative 'sequencer'

module Segmenter
  state do
    interface input, :frame_requests, [:key, :start] => [:size]
    interface output, :frames, [:key, :start] => [:vals]
    interface output, :full_frames, [:key, :start] => [:vals]
    scratch :intermediate, [:key, :start] => [:pairs]
    scratch :frames_with_index, [:key, :start] => [:pairs]
  end

  bloom do

    intermediate <= frame_requests.map do |req|
      [
        req.key, req.start,
        sequence.map do |s|
          s if req.start <= s.timestamp && s.timestamp < (req.start + req.size)
        end
      ]
    end

    frames_with_index <= intermediate do |s|
      s if s.pairs.length > 0
    end
  end

  bloom :getFrames do
    frames <= frames_with_index.map do |frame|
      [frame.key, frame.start, frame.pairs.map { |pair| pair[1] }]
    end

    full_frames <= (frames * frame_requests).pairs do |frame, req|
      frame if frame.vals.length == req.size
    end
  end
end

if __FILE__ == $0
  class Main
    include Bud
    include Sequencer
    include Segmenter
    bloom do
      # stdio <~ frame_requests.inspected
      # stdio <~ intermediate.inspected
      stdio <~ frames.inspected
      # stdio <~ full_frames.inspected
    end
  end

  h = Main.new
  h.run_bg
  h.sync_do { h.input_stream <+ [[123, 1, [6,7,8]], [127, 1, [9,10,11]], [545, 1, [0,1,2,3]]] }
  h.sync_do { h.frame_requests <+ [['first', 123, 5], ['second', 545, 2], ['third', 600, 1]] }
  h.tick
end
