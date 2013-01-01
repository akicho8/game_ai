# -*- coding: utf-8 -*-

class Task
  @@all = []

  def self.all
    @@all
  end

  def self.dump(method)
    @@all.collect{|a|
      a.send(method).collect{|b|
        "#{a.name} → #{b.name}"
      }
    }.flatten
  end

  attr_accessor :name, :next_tasks, :prev_tasks

  def initialize(name)
    @@all << self
    @name = name
    @prev_tasks = []
    @next_tasks = []
  end

  def chain(task)
    @next_tasks << task
    task.prev_tasks << self
  end
end

#
# A -----> B -----> C
#
a = Task.new("A")
b = Task.new("B")
c = Task.new("C")
a.chain(b)
b.chain(c)
Task.dump(:next_tasks)  # => ["A → B", "B → C"]
Task.dump(:prev_tasks)  # => ["B → A", "C → B"]

#
#     +--> X --+
# A --+        +--> C
#     +--> Y --+
#

Task.all.clear
a = Task.new("A")
x = Task.new("X")
y = Task.new("Y")
c = Task.new("C")
a.chain(x)
a.chain(y)
x.chain(c)
y.chain(c)
Task.dump(:next_tasks)  # => ["A → X", "A → Y", "X → C", "Y → C"]
Task.dump(:prev_tasks)  # => ["X → A", "Y → A", "C → X", "C → Y"]

class Task
  # 前のタスクが終わっているか？(このタスクが実行可能か？)
  def active?
    @prev_tasks.all?{|t|t.completed?}
  end

  # このタスクが終了したか？
  def completed?
    # player.items.include?(@name)
  end
end
