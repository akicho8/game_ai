# -*- coding: utf-8 -*-
#
# ベイズ法を使った攻撃予想
#
# 参照: ゲーム開発者のためのAI入門 P.266
#
# サイズ2の履歴に [:a, :b] の履歴があり、次に :c が来たとき
# [:a, :b] となった回数と、[:a, :b, :c] となった回数を ++ して
# 履歴を [:a, :b, :c] としてずらして [:b, :c] として
# [:b, :c] の回数が 4 としたら [:b, :c] のあとに a, b, c が来るときの回数を順に調べて
#   [:b, :c, :a] の回数 3 てことは b→cまで来る流れは4回あってその次にaが来るのは3回なので確率は 3/4 = 0.75
#   [:b, :c, :b] の回数 2 てことは b→cまで来る流れは4回あってその次にbが来るのは2回なので確率は 2/4 = 0.50
#   [:b, :c, :c] の回数 1 てことは b→cまで来る流れは4回あってその次にcが来るのは1回なので確率は 1/4 = 0.25
# として 0.75 になる :a になる可能性が高いことがわかる
#

require "rain_table"

class BayesianProb
  attr_reader :queue, :counts, :next_counts, :options, :keys

  def initialize(keys, options = {})
    @options = {
      :queue_size => 1,         # 過去何個の履歴を見るか
    }.merge(options)

    @keys = keys
    @counts = {}
    @next_counts = {}
    @queue = []
  end

  def process(input)
    @counts[@queue] ||= 0
    @counts[@queue] += 1
    @next_counts[@queue + [input]] ||= 0
    @next_counts[@queue + [input]] += 1

    @queue = (@queue + [input]).last(@options[:queue_size])

    prob = {}
    @keys.each do |key|
      if v = @next_counts[@queue + [key]]
        if @counts[@queue]
          v = v.to_f / @counts[@queue]
        end
        prob.update(key => v.to_f)
      end
    end

    Hash[prob.sort_by{|k, v|-v}] # 確率が高い順のハッシュにする
  end

  def stat
    {
      :queue => @queue,
      :counts => @counts,
      :next_counts => @next_counts,
    }
  end
end

obj = BayesianProb.new([:p, :k], :queue_size => 1)
obj.process(:p)                 # => {}
obj.process(:p)                 # => {:p=>1.0}
obj.process(:k)                 # => {}
obj.process(:k)                 # => {:k=>1.0}
obj.process(:p)                 # => {:p=>0.5, :k=>0.5}
obj.process(:p)                 # => {:p=>0.6666666666666666, :k=>0.3333333333333333}
obj.process(:p)                 # => {:p=>0.75, :k=>0.25}
tt obj.stat
# >> +-------------+---------------------------------------------------------------+
# >> | queue       | [:p]                                                          |
# >> | counts      | {[]=>1, [:p]=>4, [:k]=>2}                                     |
# >> | next_counts | {[:p]=>1, [:p, :p]=>3, [:p, :k]=>1, [:k, :k]=>1, [:k, :p]=>1} |
# >> +-------------+---------------------------------------------------------------+
