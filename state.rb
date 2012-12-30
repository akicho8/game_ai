# -*- coding: utf-8 -*-

require "active_support/core_ext/string"

module Statable
  attr_reader :counter, :key

  def initialize(key)
    transition(key)
  end

  def transition(key)
    @key = key
    @counter = 0
  end

  def transition!(key)
    transition(key)
    throw :transit
  end

  def transition_loop(&block)
    begin
      ret = catch(:transit) do
        yield
        true
      end
    end until ret == true
    @counter += 1
  end
end

class State
  include Statable
end

state = State.new(:mode_a)
3.times do
  state.transition_loop do
    case state.key
    when :mode_a
      if state.counter == 1
        state.transition! :mode_b
      end
    when :mode_b
      # ...
    end
  end
end


class State
  attr_reader :counter, :current

  def initialize(*args)
    transition(*args)
  end

  def transition(key, *args)
    @current = key.to_s.classify.constantize.new(*args)
  end

  def transition!(key, *args)
    transition(key, *args)
    throw "transit_#{object_id}".to_sym
  end

  def run
    begin
      ret = catch("transit_#{object_id}".to_sym) do
        @current.run
        true
      end
    end until ret == true
    @current.counter += 1
  end
end

class Player
  attr_accessor :state
  def initialize
    @state = State.new(:mode_a, self)
  end
  def run
    @state.run
  end
  def top_level_transition!(key)
    @state.transition!(key, self)
  end
end

class StateBase
  attr_accessor :player, :counter, :sub_state
  def initialize(player)
    @player = player
    @counter = 0
  end
  def run
    if @sub_state
      @sub_state.run
    end
  end
end

class ModeA < StateBase
  def run
    if @counter == 1
      p "a"
      @sub_state = State.new(:mode_a1, @player)
    end
    super
  end
end

class ModeA1 < StateBase
  def run
    p "a1"
    @player.top_level_transition!(:mode_b)
    super
  end
end

class ModeB < StateBase
  def run
    if @counter == 1
      p "b"
      @sub_state = State.new(:mode_b1, @player)
    end
    super
  end
end

class ModeB1 < StateBase
  def run
    p "b1"
    @player.top_level_transition!(:mode_a)
    super
  end
end

player = Player.new
3.times{ player.run }
# >> "a"
# >> "a1"
# >> "b"
# >> "b1"
