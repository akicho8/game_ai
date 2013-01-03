# -*- coding: utf-8 -*-
require "pp"

class Human
  def sleepy(t)
    Math.sin(2 * Math::PI / 24 * t)
  end
end

human = Human.new
0.step(24, 6).collect{|t|[t, '%.2f' % human.sleepy(t)]} # => [[0, "0.00"], [6, "1.00"], [12, "0.00"], [18, "-1.00"], [24, "-0.00"]]

class Human
  attr_accessor :hungry, :social

  def initialize
    @hungry = 0
    @social = 0
  end
end

class Apple
  def hungry(human)
    (1.0 - human.hungry) / 2.0
  end
  def social(human)
    0
  end
end

human = Human.new
apple = Apple.new
[:hungry, :social].collect{|m|[apple.send(m, human), m]} # => [[0.5, :hungry], [0, :social]]
