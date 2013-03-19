require 'rubygems'
require 'backports'
require 'bud'

require_relative 'sequencer'
require_relative 'segmenter'

## Automatically produces data frames of specificed size and stride lengths
## depending on the minimum and maximum time-stamp present in the sequence.
module AutoSegmenter
  state do
    table :frame_specs, [:key] => [:stride, :size]
  end

  bloom do
    temp :minSeqTime <= sequence.group([], min(:timestamp))
    temp :maxSeqTime <= sequence.group([], max(:timestamp))

    # Recursively build up requests depending on length of sequence.
    frame_requests <= (frame_specs * minSeqTime).pairs { |s, minT| [s.key, minT[0], s.size] }
    frame_requests <= (frame_specs * frame_requests * maxSeqTime) \
        .combos(frame_specs.key => frame_requests.key) do |s, q, maxT|
          [s.key, q.start + s.stride, s.size] if q.start < maxT[0]
        end
  end
end

if __FILE__ == $0
  class Main
    include Bud  
    include Sequencer
    include Segmenter
    include AutoSegmenter
    bloom do
      # stdio <~ frame_requests.inspected
      # stdio <~ frame_requests.inspected
      # stdio <~ frames_with_index.inspected
      stdio <~ frames.inspected
      # stdio <~ full_frames.inspected
    end
  end

  h = Main.new
  h.run_bg
  h.sync_do { h.input_stream <+ [[123, 1, [6,7,8]], [545, 1, [0,1,2,3]]] }
  h.sync_do { h.frame_specs <+ [['first', 3, 3], ['second', 1, 1]] }
  h.tick
end
