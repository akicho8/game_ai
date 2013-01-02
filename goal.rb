# -*- coding: utf-8 -*-
class Goal
  # 成功したか？
  def completed?
  end

  # 開始できるか？ (毎回呼ばれるので今、有効か？の意味でもある)
  def activate?
  end

  # 処理内容
  def process
    # completed, active, failed を返す
  end

  # 後処理
  def after_process
    # completed, failed に応じた処理
  end
end

# 実装してみる

class Goal
  def initialize
    @counter = 0
    @status = 0
  end

  def completed?
    true
  end

  def activate?
    true
  end

  def process
    @status = :active
    if @counter >= 1
      if completed?
        @status = :completed
      end
    end
    @counter += 1
    @status
  end

  def after_process
    puts @status
  end
end

goal = Goal.new
loop do
  if goal.activate?
    status = goal.process
    goal.after_process
    unless status == :active
      break
    end
  end
end
# >> active
# >> completed

class CompositeGoal < Goal
  def initialize
    @counter = 0
    @status = 0
    @goals = []
  end

  def completed?
    true
  end

  def activate?
    true
  end

  def process
    @status = :active
    @goals.each{|e|e.process}
    if @goals.any?{|e|e.completed?}
      @status = :completed
    end
    @status
  end

  def after_process
    @goals.each(&:after_process)
  end
end
