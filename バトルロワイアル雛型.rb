# -*- coding: utf-8 -*-
# バトルロワイアル雛型

class Player
  attr_accessor :life, :name

  def initialize(name)
    @name = name
    @life = 9999
  end

  def run
    target = (Battle.players - [self]).sample
    attack = rand(1000..5000)
    puts "#{name} が #{target.name} に #{attack} のダメージ"
    target.life -= attack
    if target.life <= 0
      puts "#{target.name} を倒した"
      Battle.players.delete(target)
    end
  end
end

module Battle
  extend self
  attr_accessor :players

  def run
    @players = 3.times.collect.with_index {|i| Player.new("P#{i}") }
    @players.cycle do |player|
      player.run
      if @players.size == 1
        puts "#{@players.first.name} が生き残った"
        break
      end
    end
  end
end

Battle.run
# >> P0 が P2 に 3225 のダメージ
# >> P1 が P0 に 3483 のダメージ
# >> P2 が P1 に 4367 のダメージ
# >> P0 が P1 に 1934 のダメージ
# >> P1 が P0 に 4482 のダメージ
# >> P2 が P1 に 1549 のダメージ
# >> P0 が P1 に 4009 のダメージ
# >> P1 を倒した
# >> P2 が P0 に 1229 のダメージ
# >> P0 が P2 に 3319 のダメージ
# >> P2 が P0 に 1342 のダメージ
# >> P0 を倒した
# >> P2 が生き残った
