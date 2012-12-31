# -*- coding: utf-8 -*-

require "./tree"

# 選択方法を知っている配列
class Box
  attr_accessor :selector, :list

  def initialize
    @selector = "確率的選択"
    @list = []
  end

  def <<(node)
    @list << node
  end

  def get_by_selector
    nodes = @list.find_all{|n|n.executable?}
    case @selector
    when "確率的選択"
      nodes.sample
    when "優先度リスト"
      # 優先度の高いもの順
    when "シーケンシャル"
      # 決まった順に。
    when "シーケンシャルルーピング"
      # 決まった順に繰り返す
    when "オンオフ"
      # ランダムだけど一度選択したものは選択しない
    end
  end
end

class Behavior < Tree::Node
  attr_accessor :box          # この中の list に複数の子ビヘイビアが入る

  def initialize(*args)
    super
    @box = nil           # 子ビヘイビアはただの配列ではなく「選択方法」を知っている配列でないといけない
  end

  # 各ビヘイビアは現在の状況で実行可能かどうかを自分自身で宣言する→宣言的手法
  def executable?
    true
  end

  # for tree method
  def nodes
    if @box
      @box.list
    else
      []
    end
  end
end

class Builder
  attr_reader :root

  def self.build(*args, &block)
    new(*args).tap{|o|o.instance_eval(&block)}.root
  end

  def initialize(root = nil)
    @root = root || Behavior.new("root")
  end

  def add(name, options = {}, &block)
    node = Behavior.new(name)
    node.parent = @root
    @root.box ||= Box.new
    @root.box << node
    if block_given?
      self.class.new(node).instance_eval(&block)
    end
    self
  end
end

root = Builder.build do
  add("交戦") do
    add("攻撃") do
      add("剣を振る")
      add("攻撃魔法") do
        add("召喚A")
        add("召喚B")
      end
      add("縦で剣をはじく")
    end
    add("防御") do
      add("一歩後退する")
      add("縦で身を隠す")
    end
  end
  add("撤退") do
    add("足止めする") do
      add("トラップをしかける")
      add("弓矢を放つ")
    end
    add("逃走する")
  end
  add("休憩") do
    add("立ち止まる")
    add("回復する") do
      add("回復魔法")
      add("回復薬を飲む")
    end
  end
end

puts root.tree

# シンプルに選択していく例。だけどこれは正しくない。nodes のどれを選択するかは nodes が知っていないといけないから。つまり nodes がただの Array クラスになっているのがまずい。

node = root
loop do
  nodes = node.nodes                       # 子ビヘイビアたちを
  nodes = nodes.find_all{|n|n.executable?} # 今実行できるものたちに絞って
  break if nodes.empty?                    # いなくなってたらあきらめて
  node = nodes.sample                      # いたらランダムに選択
  node.key # => "撤退", "逃走する"
end

# 改善

node = root
loop do
  break unless node.box
  node = node.box.get_by_selector
  node.key # => "休憩", "回復する", "回復薬を飲む"
end

# 「攻撃(a)」の下にぶらさがる木を「逃走する(b)」の下に移動する(boxを移動させる)
# [0]とか[1]とかあるけどここはハッシュで一発選択させたいところ

a = root.box.list[0].box.list[0]   # 攻撃のノードを取得
a_box = a.box                      # 攻撃の下の木をいったん退避
a.box = nil                          # そこは無くなるので nil にしとく

b = root.box.list[1].box.list.last # 「逃走する」のノードを取得して
a_box.list.each{|n|n.parent = b}     # 親を変更して(←これ本来は不要。treeモジュール表示に必要だから入れてるだけ)
b.box = a_box                      # 逃走するにぶらさがるグループを置き換え

puts root.tree

# >> root
# >> ├─交戦
# >> │   ├─攻撃
# >> │   │   ├─剣を振る
# >> │   │   ├─攻撃魔法
# >> │   │   │   ├─召喚A
# >> │   │   │   └─召喚B
# >> │   │   └─縦で剣をはじく
# >> │   └─防御
# >> │       ├─一歩後退する
# >> │       └─縦で身を隠す
# >> ├─撤退
# >> │   ├─足止めする
# >> │   │   ├─トラップをしかける
# >> │   │   └─弓矢を放つ
# >> │   └─逃走する
# >> └─休憩
# >>     ├─立ち止まる
# >>     └─回復する
# >>         ├─回復魔法
# >>         └─回復薬を飲む
# >> root
# >> ├─交戦
# >> │   ├─攻撃
# >> │   └─防御
# >> │       ├─一歩後退する
# >> │       └─縦で身を隠す
# >> ├─撤退
# >> │   ├─足止めする
# >> │   │   ├─トラップをしかける
# >> │   │   └─弓矢を放つ
# >> │   └─逃走する
# >> │       ├─剣を振る
# >> │       ├─攻撃魔法
# >> │       │   ├─召喚A
# >> │       │   └─召喚B
# >> │       └─縦で剣をはじく
# >> └─休憩
# >>     ├─立ち止まる
# >>     └─回復する
# >>         ├─回復魔法
# >>         └─回復薬を飲む
