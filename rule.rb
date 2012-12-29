# -*- coding: utf-8 -*-
class Player < Hash
end

class Rule < Hash
  def evaluate(player)
    (self[:base] || 0) + self[:a] * player[:hp] + self[:b] * player[:distance]
  end
end

class RuleSelector
  attr_accessor :rules
  def initialize
    @rules = []
  end
  def choice(player)
    @rules.collect{|r|r.evaluate(player)} # => [5.6000000000000005, 7.0], [9.2, 6.4], [5.6000000000000005, 7.0, 15.0]
    @rules.sort_by{|r|r.evaluate(player)}.last
  end
end

player1 = Player[:hp =>  5, :distance => 7]
player2 = Player[:hp => 10, :distance => 5]

selector = RuleSelector.new
selector.rules << Rule[:name => "逃げる", :base => 0.2, :a => 0.8, :b => 0.2]
selector.rules << Rule[:name => "追う",   :base => 0.4, :a => 0.2, :b => 0.8]
selector.choice(player1)[:name]  # => "追う"
selector.choice(player2)[:name]  # => "逃げる"

selector.rules << Rule[:name => "飛ぶ",   :base => 9.0, :a => 0.5, :b => 0.5]
selector.choice(player1)[:name]  # => "飛ぶ"
