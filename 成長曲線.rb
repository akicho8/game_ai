# -*- coding: utf-8 -*-
#
# 成長曲線
#

require "bundler/setup"
require "rain_table"
require "stylet/vector"
require "gnuplot"
require "pp"

Vec = Stylet::Vector

class GrowthCurveRand
  def rate(max_level, level)
    rand
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

    t.select{|t|(0.0..1.0).include?(t)} # !> shadowing outer local variable - t
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
    c = (s0.x * s1.y - s1.x * s0.y) # !> assigned but unused variable - id

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
# >> +-------+---------+---------+--------+------+-------+-------+--------+
# >> | level | 超早熟A | 超早熟B | 超早熟 | 早熟 | 普通  | 晩成  | 超晩成 |
# >> +-------+---------+---------+--------+------+-------+-------+--------+
# >> |     0 |       0 |    8000 |      0 |    0 |     0 |     0 |      0 |
# >> |     1 |     915 |    8000 |    932 |  505 |   200 |    79 |     44 |
# >> |     2 |    1517 |    8000 |   1676 |  975 |   400 |   161 |     89 |
# >> |     3 |    2000 |    8000 |   2299 | 1413 |   600 |   244 |    135 |
# >> |     4 |    2416 |    8000 |   2838 | 1825 |   800 |   329 |    183 |
# >> |     5 |    2786 |    8000 |   3311 | 2212 |  1000 |   416 |    233 |
# >> |     6 |    3123 |    8000 |   3733 | 2578 |  1200 |   505 |    284 |
# >> |     7 |    3435 |    8000 |   4114 | 2925 |  1400 |   596 |    337 |
# >> |     8 |    3726 |    8000 |   4459 | 3254 |  1600 |   689 |    391 |
# >> |     9 |    4000 |    8000 |   4774 | 3567 |  1800 |   784 |    448 |
# >> |    10 |    4260 |    8000 |   5064 | 3865 |  2000 |   881 |    506 |
# >> |    11 |    4508 |    8000 |   5331 | 4150 |  2200 |   981 |    565 |
# >> |    12 |    4745 |    8000 |   5577 | 4422 |  2400 |  1083 |    627 |
# >> |    13 |    4972 |    8000 |   5806 | 4682 |  2600 |  1187 |    690 |
# >> |    14 |    5191 |    8000 |   6018 | 4931 |  2800 |  1294 |    756 |
# >> |    15 |    5403 |    8000 |   6216 | 5170 |  3000 |  1403 |    823 |
# >> |    16 |    5608 |    8000 |   6400 | 5400 |  3200 |  1514 |    892 |
# >> |    17 |    5807 |    8000 |   6572 | 5621 |  3400 |  1628 |    964 |
# >> |    18 |    6000 |    8000 |   6732 | 5833 |  3600 |  1745 |   1037 |
# >> |    19 |    6188 |    8000 |   6882 | 6037 |  3800 |  1864 |   1113 |
# >> |    20 |    6371 |    8000 |   7022 | 6233 |  4000 |  1986 |   1191 |
# >> |    21 |    6550 |    8000 |   7153 | 6423 |  4200 |  2112 |   1271 |
# >> |    22 |    6724 |    8000 |   7275 | 6605 |  4400 |  2240 |   1353 |
# >> |    23 |    6895 |    8000 |   7390 | 6781 |  4600 |  2371 |   1438 |
# >> |    24 |    7062 |    8000 |   7496 | 6951 |  4800 |  2505 |   1526 |
# >> |    25 |    7226 |    8000 |   7596 | 7114 |  5000 |  2642 |   1616 |
# >> |    26 |    7386 |    8000 |   7689 | 7272 |  5200 |  2783 |   1708 |
# >> |    27 |    7544 |    8000 |   7775 | 7425 |  5400 |  2927 |   1804 |
# >> |    28 |    7699 |    8000 |   7856 | 7572 |  5600 |  3075 |   1902 |
# >> |    29 |    7851 |    8000 |   7931 | 7715 |  5800 |  3226 |   2003 |
# >> |    30 |    8000 |    8000 |   8000 | 7852 |  6000 |  3382 |   2107 |
# >> |    31 |         |         |        | 7985 |  6200 |  3541 |   2214 |
# >> |    32 |         |         |        | 8114 |  6400 |  3704 |   2325 |
# >> |    33 |         |         |        | 8238 |  6600 |  3871 |   2438 |
# >> |    34 |         |         |        | 8358 |  6800 |  4043 |   2555 |
# >> |    35 |         |         |        | 8475 |  7000 |  4219 |   2676 |
# >> |    36 |         |         |        | 8587 |  7200 |  4400 |   2801 |
# >> |    37 |         |         |        | 8695 |  7400 |  4586 |   2929 |
# >> |    38 |         |         |        | 8800 |  7600 |  4777 |   3061 |
# >> |    39 |         |         |        | 8902 |  7800 |  4973 |   3198 |
# >> |    40 |         |         |        | 9000 |  8000 |  5175 |   3339 |
# >> |    41 |         |         |        |      |  8200 |  5382 |   3484 |
# >> |    42 |         |         |        |      |  8400 |  5596 |   3634 |
# >> |    43 |         |         |        |      |  8600 |  5816 |   3789 |
# >> |    44 |         |         |        |      |  8800 |  6042 |   3949 |
# >> |    45 |         |         |        |      |  9000 |  6276 |   4115 |
# >> |    46 |         |         |        |      |  9200 |  6517 |   4286 |
# >> |    47 |         |         |        |      |  9400 |  6766 |   4464 |
# >> |    48 |         |         |        |      |  9600 |  7023 |   4648 |
# >> |    49 |         |         |        |      |  9800 |  7289 |   4838 |
# >> |    50 |         |         |        |      | 10000 |  7564 |   5036 |
# >> |    51 |         |         |        |      |       |  7849 |   5241 |
# >> |    52 |         |         |        |      |       |  8144 |   5455 |
# >> |    53 |         |         |        |      |       |  8451 |   5676 |
# >> |    54 |         |         |        |      |       |  8769 |   5908 |
# >> |    55 |         |         |        |      |       |  9101 |   6148 |
# >> |    56 |         |         |        |      |       |  9447 |   6400 |
# >> |    57 |         |         |        |      |       |  9809 |   6663 |
# >> |    58 |         |         |        |      |       | 10187 |   6939 |
# >> |    59 |         |         |        |      |       | 10583 |   7228 |
# >> |    60 |         |         |        |      |       | 11000 |   7532 |
# >> +-------+---------+---------+--------+------+-------+-------+--------+
# >> writing this to gnuplot:
# >> set terminal png font 'Ricty-Bold.ttf'
# >> set output "_output_all.png"
# >> set title "成長曲線"
# >> set ylabel "攻撃力"
# >> set xlabel "Level"
# >> set key right bottom
# >> 
