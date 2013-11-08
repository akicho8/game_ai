# -*- coding: utf-8 -*-
#
# 成長曲線
#

$LOAD_PATH.unshift("~/src/rain_table/lib")
$LOAD_PATH.unshift("~/src/stylet_math/lib")

require "pp"
require "gnuplot"
require "rain_table"
require "stylet/vector"

Vec = Stylet::Vector

class GrowthCurveRand
  # def self.output_graph(graph_data)
  #   Gnuplot.open do |gp|
  #     Gnuplot::Plot.new(gp) do |plot|
  #       plot.terminal "png font 'Ricty-Regular.ttf'"
  #       plot.output "_output_#{name.downcase}.png"
  #       plot.title  "Growth Curve"
  #       plot.ylabel "ATK"
  #       plot.data << Gnuplot::DataSet.new([graph_data.collect{|e|e[:level]}, graph_data.collect.collect{|e|e[:rate]}]) do |ds|
  #         ds.with = "linespoints pointtype 7 pointsize 1"
  #         ds.notitle
  #       end
  #     end
  #   end
  # end

  # attr_accessor :max_level

  # def initialize(max_level)
  #   @max_level = max_level
  # end

  def rate(max_level, level)
    rand
  end

  # def graph_data
  #   (0..@max_level).collect {|level| {:level => level, :rate => rate(level)} }
  # end

  def output_graph
    self.class.output_graph(graph_data)
  end
end

# レベルに比例
class GrowthCurve1 < GrowthCurveRand
  def rate(max_level, level)
    level.to_f / max_level
  end
end

# ベジェ曲線上を左下端から右上端まで歩くとしてレベルに比例した位置のY座標
class GrowthCurve2 < GrowthCurveRand
  def initialize(control_point)
    @points = [Vec[0.0, 0.0], control_point, Vec[1.0, 1.0]]
  end

  # x = p0.x*(1-t)*(1-t) + 2*p1.x*t*(1-t) + p2.x*t*t
  # y = p0.y*(1-t)*(1-t) + 2*p1.y*t*(1-t) + p2.y*t*t
  def bezier_curve(p0, p1, p2, t)
    v = Vec[0.0, 0.0]
    v += p0 * ((1 - t) * (1 - t))
    v += p1 * (2 * t * (1 - t))
    v += p2 * (t * t)
  end

  # ベジェ曲線上を左下端から右上端まで歩くとしてレベルに比例した位置のY座標
  def rate(max_level, level)
    bezier_curve(*@points, level.to_f / max_level).y
  end
end

# レベルをX座標を見なしてX軸に垂直な直線とベジェ曲線の交点のY座標
class GrowthCurve3 < GrowthCurve2
  # 二次ベジェ曲線と直線の交点
  # http://geom.web.fc2.com/geometry/bezier/qb-line-intersection.html
  def intersection(p0, p1, p2, a, b, c)
    # l = a*(p2.x-2*p1.x+p0.x)+b*(p2.y-2*p1.y+p0.y)
    # m = 2*(a*(p1.x-p0.x)+b*(p1.y-p0.y))
    # n = a*p0.x+b*p0.y+c
    # d = (m**2)-4*l*n
    # t = []
    # if d > 0
    #   s = Math.sqrt(d)
    #   t << (-m+s) / (2*l)
    #   t << (-m-s) / (2*l)
    # elsif d.zero?
    #   t << -m/(2*l)
    # end

    l = a.to_f*(p2.x.to_f-2.0*p1.x.to_f+p0.x.to_f)+b.to_f*(p2.y.to_f-2.0*p1.y.to_f+p0.y.to_f)
    m = 2.0*(a.to_f*(p1.x.to_f-p0.x.to_f)+b.to_f*(p1.y.to_f-p0.y.to_f))
    n = a.to_f*p0.x.to_f+b.to_f*p0.y.to_f+c.to_f
    d = (m.to_f**2)-4.0*l.to_f*n.to_f
    t = []
    if d > 0
      s = Math.sqrt(d)
      t << (-m+s).to_f / (2.0*l)
      t << (-m-s).to_f / (2.0*l)
    elsif d.zero?
      t << -m.to_f / (2.0*l)
    end

    t.select{|t|(0.0..1.0).include?(t)} # !> assigned but unused variable - id
  end

  # レベルをX座標を見なしてX軸に垂直な直線とベジェ曲線の交点のY座標
  def rate(max_level, level)
    # 制御点が中央 [0.5, 0.5] の場合、また交点が見つからなくなるのでやっつけ対応(あとで確認)
    if @points[1].x == 0.5 && @points[1].y == 0.5
      return level.to_f / max_level
      # return bezier_curve(*@points, level.to_f / max_level).y
    end

    # # 最後に誤差が生まれて 1.0 にならない場合があるのでやっつけ対応
    # if level == max_level
    #   return 1.0
    # end

    # X軸に垂直な s0 s1 を通る直線
    s0 = Vec[level.to_f / max_level, 0.0]
    s1 = Vec[level.to_f / max_level, 1.0]

    a = s0.y - s1.y
    b = -(s0.x - s1.x)
    c = (s0.x * s1.y - s1.x * s0.y)

    # 交点を調べると曲線位置(t)が求まる
    t = intersection(*@points, a, b, c)

    # p2.x と s0〜s1 を通る直線の x 座標が同じ場合交点が見つからないので着いたことにする
    if t.empty?
      t = [1.0]
      # t = [0.0]
    end

    # tの実際の座標を求める
    bezier_curve(*@points, t.first).y
  end
end

max_level = 60

patterns = []
# patterns << GrowthCurve1.new("レベル比例", max_level, @max_atk)
# patterns << GrowthCurve2.new("曲線歩き(早熟)", max_level, @max_atk, Vec[0.5 - 0.3, 0.5 + 0.3])
# patterns << GrowthCurve2.new("曲線歩き(普通)", max_level, @max_atk, Vec[0.5, 0.5])

# patterns << GrowthCurve3.new(max_level, 10000 - 2000, Vec[0.5 - 0.4, 0.5 + 0.4])
# patterns << GrowthCurve3.new(max_level, 10000 - 1000, Vec[0.5 - 0.2, 0.5 + 0.2])
# patterns << GrowthCurve3.new(max_level, 10000,        Vec[0.5, 0.5])
# patterns << GrowthCurve3.new(max_level, 10000 + 1000, Vec[0.5 + 0.2, 0.5 - 0.2])
# patterns << GrowthCurve3.new(max_level, 10000 + 2000, Vec[0.5 + 0.4, 0.5 - 0.4])

patterns << {:name => "超早熟A", :res => GrowthCurve3.new(Vec[0.5 - 0.4, 0.5 - 0.0]), :max_level => 30, :max_atk => 10000 - 2000}
patterns << {:name => "超早熟B", :res => GrowthCurve3.new(Vec[0.5, 0.6]), :max_level => 30, :max_atk => 10000 - 2000} # ← 動かない
patterns << {:name => "超早熟", :res => GrowthCurve3.new(Vec[0.5 - 0.3, 0.5 + 0.3]), :max_level => 30, :max_atk => 10000 - 2000}
patterns << {:name => "早熟",   :res => GrowthCurve3.new(Vec[0.5 - 0.2, 0.5 + 0.2]), :max_level => 40, :max_atk => 10000 - 1000}
patterns << {:name => "普通",   :res => GrowthCurve3.new(Vec[0.5 + 0.0, 0.5 + 0.0]), :max_level => 50, :max_atk => 10000 +    0}
patterns << {:name => "晩成",   :res => GrowthCurve3.new(Vec[0.5 + 0.2, 0.5 - 0.2]), :max_level => 60, :max_atk => 10000 + 1000}
patterns << {:name => "超晩成", :res => GrowthCurve3.new(Vec[0.5 + 0.3, 0.5 - 0.3]), :max_level => 70, :max_atk => 10000 + 2000}

records = (0..max_level).collect do |level|
  attrs = {}
  attrs[:level] = level
  patterns.each.with_index do |e, i|
    if level <= e[:max_level]
      attrs[e[:name]] = (e[:max_atk].to_f * e[:res].rate(e[:max_level], level)).round
    end
  end
  attrs
end
tt records

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.terminal "png font 'Ricty-Bold.ttf'"
    plot.output "_output_all.png"
    plot.title  "成長曲線"
    plot.ylabel "攻撃力"
    plot.xlabel "Level"
    plot.key "right bottom"
    plot.data = patterns.collect do |e|
      x = (0..e[:max_level]).to_a
      y = (0..e[:max_level]).collect{|level|(e[:max_atk].to_f * e[:res].rate(e[:max_level], level)).round}
      Gnuplot::DataSet.new([x, y]) do |ds|
        ds.with = "linespoints pointtype 7 pointsize 1.5"
        # ds.notitle
        ds.title = e[:name]
      end
    end
  end
end
`open _output_all.png`

# >> +-------+----------------+----------------+
# >> | level | 垂直交点(早熟) | 垂直交点(普通) |
# >> +-------+----------------+----------------+
# >> |     0 |              0 |              0 |
# >> |     1 |           2874 |           1000 |
# >> |     2 |           4666 |           2000 |
# >> |     3 |           5968 |           3000 |
# >> |     4 |           6971 |           4000 |
# >> |     5 |           7769 |           5000 |
# >> |     6 |           8415 |           6000 |
# >> |     7 |           8941 |           7000 |
# >> |     8 |           9370 |           8000 |
# >> |     9 |           9719 |           9000 |
# >> |    10 |          10000 |          10000 |
# >> +-------+----------------+----------------+
# >> writing this to gnuplot:
# >> set terminal png font 'Ricty-Regular.ttf'
# >> set output "_output_all.png"
# >> set title "Growth Curve"
# >> set ylabel "atk"
# >>
