require 'rubygems'
require 'backports'
require 'bud'
require 'matrix'
require_relative '../protocol'

class GMMService
  include Bud
  include SpeakerRecognizeProtocol
  state do
  	interface input, :featureIn, [:ts, :val]
    interface input, :mixParams, [:gmm_id, :mix_id] => [:weight, :mu, :sigma]

    table :params, [:gmm_id, :mix_id] => [:weight, :mu_neg, :sigma_inv, :log_sigma_weight, :pi_param]

    scratch :mixtureProb, [:gmm_id, :mix_id] => [:pr]
    scratch :maxMixtureProb, [:gmm_id, :mix_id] => [:pr]
    scratch :expMixtureProb, [:gmm_id, :mix_id] => [:pr]
    scratch :sumExpMixtureProbs, [:gmm_id] => [:pr]
    scratch :logSumExpMixtureProbs, [:gmm_id, :pr]
  end

  bloom :doGet do
    featureIn <= mfccChannel {|m| [m.ts, m.mfcc]}
    stdio <~ mfccChannel {|m| puts "Request from #{m.replyTo}: #{m.mfcc}"}
    stdio <~ logSumExpMixtureProbs.inspected
    gmmChannel <~ (mfccChannel * logSumExpMixtureProbs).combos {|m, res| [m.replyTo, m.ts, [res.gmm_id, res.pr]]}

  end

  bloom :storeGMM do
    params <= mixParams.map do |p|
      [p.gmm_id, p.mix_id,
       p.weight,
       p.mu.map { |x| -x },
       p.sigma.map { |e| 1.0 / e },
       Math.log(p.weight) - 0.5 * Math.log(p.sigma.inject(:+)),
      -0.5 * p.mu.length * Math.log(2 * 3.14)]
    end
  end

  bloom :featureInput do
    mixtureProb <= (featureIn * params).combos do |f, p|
      [p.gmm_id, p.mix_id, \
       p.log_sigma_weight - 0.5 * \
       dot(p.sigma_inv, pow(vecsum(f.val, p.mu_neg), 2))]
    end

    maxMixtureProb <= mixtureProb.argmax([:gmm_id], mixtureProb.pr)

    expMixtureProb <= (maxMixtureProb * mixtureProb) \
    .combos(maxMixtureProb.gmm_id => mixtureProb.gmm_id) do |maxMixture, mixture|
      [mixture.gmm_id, mixture.mix_id, Math.exp(mixture.pr - maxMixture.pr)]
    end

    sumExpMixtureProbs <= expMixtureProb.group([:gmm_id], sum(:pr))

    logSumExpMixtureProbs <= (sumExpMixtureProbs * maxMixtureProb * params) \
    .combos(sumExpMixtureProbs.gmm_id => params.gmm_id, \
            sumExpMixtureProbs.gmm_id => maxMixtureProb.gmm_id) do |s, m, p|
      [s.gmm_id, Math.log(s.pr) + m.pr + p.pi_param]
    end
  end

  def dot(a,b)
    return a.zip(b).inject(0) {|sum,(w,d)| sum + w * d }
  end

  def vecsum(a,b)
    return a.zip(b).map {|(a_e,b_e)| a_e + b_e }
  end
  
  def pow(a, pwr)
    return a.map { |x| x**pwr }
  end

end

if __FILE__ == $0
  h = GMMService.new(:ip => "localhost", :port => 12345)
  puts "GMM server starting..."
  h.mixParams <+ [['Kasturi', 1, 0.2, [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 7.0], [2.0, 3.0, 1.0, 5.0, 1.0, 2.0, 1.0, 6.0, 1.0, 4.0, 1.0, 8.0, 1.0]]]
  h.mixParams <+ [['Kasturi', 2, 0.8, [5.0, 0.0, 1.0, 2.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 9.0], [4.0, 3.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 6.0]]]
  h.mixParams <+ [['Chenguang', 3, 0.3, [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 2.0], [5.0, 3.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 3.0]]]
  h.mixParams <+ [['Chenguang', 4, 0.7, [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 2.0], [5.0, 3.0, 1.0, 1.0, 1.0, 7.8, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 3.0]]]
  h.run_fg
end
