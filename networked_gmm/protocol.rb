module SpeakerRecognizeProtocol
  state do
    channel :mfccChannel, [:@addr, :replyTo, :ts, :mfcc]
    channel :gmmChannel, [:@addr, :ts, :gmm]
  end
end
