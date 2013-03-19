require 'rubygems'
require 'backports'
require 'bud'
require_relative '../protocol'
require 'mfcc'

class SpeakerRecognizer
  include Bud
  include SpeakerRecognizeProtocol

  state do
  	interface input, :audioIn, [:ts] => [:buffer]
    table :mfcc, [:mel, :ts]
    table :matrixPr, [:person, :pr]
    scratch :speakerPr, [:person] => [:pr]
  end
  
  # def initialize(nick, server, buffer, opts = {})
  # 	@mfcc = Mfcc::MFCC.new()
  #   @nick = nick
  #   @server = server
  #   @buffer = buffer
  #   puts "SpeakerRecognizer client starting..."
  #   puts "Server address: #{@server}"
  #   super opts
  # end

  def initialize(opts = {})
    @mfcc = Mfcc::MFCC.new()
    @buffer = Mfcc::DoubleVector.new
    16384.times do  
      @buffer.push(1.0)
    end
    @nick = "me"
    @server = "localhost:12345"
    super opts
  end

  bloom :mfccFromAudio do
  	temp :ret <= audioIn {|a| [a.ts, @mfcc.getMFCC(a.buffer)] }
  	mfcc <= ret.flat_map do |t|
  		t.buffer.each_with_index.map { |s, ii| [s, t.ts + ii * 1] }
	  end
  end

  bloom :recgonizeSpeaker do
    audioIn <= stdio do |s|
      [Random.new(Time.new.usec).rand(100), @buffer[0, s[0].to_i]]
    end

    mfccChannel <~ mfcc do |m|
      [@server, ip_port, m.ts, m.mel]
    end
    stdio <~ gmmChannel {|g| puts "New result: sample\##{g.ts} \033[31m Pr(#{g.gmm[0]})=#{g.gmm[1]}"}
    
    matrixPr <= gmmChannel do |g|
     [g.gmm[0], g.gmm[1]]
    end
    stdio <~ (gmmChannel * speakerPr).combos{ |g, s| ["\033[37mAt sample\##{g.ts}, \033[31mPr_total(#{s.person})=#{s.pr}"]}
    speakerPr <= matrixPr.group([:person], sum(:pr))
    temp :bestProb <= speakerPr.argmax([], :pr)
    stdio <~ bestProb {|s| ["\033[37mbestProb: \033[31mPr(#{s.person})=#{s.pr}\033[37m"]}
  end
end

if __FILE__ == $0
  puts "SpeakerRecognizer client starting..."
  h = SpeakerRecognizer.new(:stdin => $stdin)
  puts "\033[37m"
  h.register_callback(:bestProb) {|x| puts "\033[37m-----END OF TICK-----"}
  h.run_fg
end

# h.sync_do { h.audioIn <+ [[1.614, buffer], [2.614, buffer]] }
# h.sync_do { h.gmmIn <+ [['Kasturi', GMM.new(mean, var2, w)]] }
# h.sync_do { h.gmmIn <+ [['Chenguang', GMM.new(mean, var1, w)]] }
# h.sync_do { h.trigger <+ [[123, 1.0]] }
# h.sync_do { h.trigger <+ [[123, 1.0]] }
# h.run_fg
