# -*- coding: utf-8 -*-
#
# 経験値曲線 二次関数版
#
# 高等学校数学I/二次関数 - Wikibooks
# http://ja.wikibooks.org/wiki/%E9%AB%98%E7%AD%89%E5%AD%A6%E6%A0%A1%E6%95%B0%E5%AD%A6I/%E4%BA%8C%E6%AC%A1%E9%96%A2%E6%95%B0
#
# y = a * (x - p)**2 + q
# x = Math.sqrt(((exp-q).to_f / a).abs) + p
# a = (y - q).to_f / ((x - p) ** 2)
#
# 開始 (p, q) 終端 (x, y) を入れると a が求まる
# x か y を入れたら片方が求まる
#

require "bundler/setup"

require "rain_table"
require "gnuplot"

class ExpCurve < Struct.new(:p, :q, :x, :y)
  def a
    (y - q).to_f / ((x - p) ** 2)
  end

  def exp_by_level(level)
    (a * (level - p) ** 2 + q).round
  end

  def level_by_exp(exp)
    Math.sqrt(((exp - q).to_f / a).abs) + p
  end

  def level_elems
    (p..x).collect do |level|
      {:lv => level, :exp => exp_by_level(level)}
    end
  end

  def exp_elems
    (q..y).step(250).collect do |exp|
      {:lv => level_by_exp(exp).round(2), :exp => exp}
    end
  end
end

def output_file(records, filename)
  Gnuplot.open do |gp|
    Gnuplot::Plot.new(gp) do |plot|
      plot.terminal "png font 'Ricty-Bold.ttf'"
      plot.output filename
      plot.title "経験値曲線"
      plot.xlabel "Level"
      plot.xtics 1
      plot.ylabel "累計経験値"
      plot.xrange "[0:*]"
      plot.yrange "[0:*]"
      records.each.with_index{|e, i|
        plot.label "#{i.next} center at first #{e[:lv]}, #{e[:exp]} '#{e[:exp]}'"
      }
      plot.data << Gnuplot::DataSet.new([records.collect{|e|e[:lv]}, records.collect{|e|e[:exp]}]) do |ds|
        ds.with = "linespoints pointtype 7 pointsize 0.0"
        ds.notitle
      end
    end
  end
end

# レベル1のとき経験値0でレベル9のとき999になる曲線でレベル5のときの経験値は？

curve = ExpCurve.new(1, 0, 20, 999)
curve.exp_by_level(15)           # => 542

# 経験値 540 のときのレベルは？

curve.level_by_exp(540)           # => 14.969077819782347

# グラフ化

records = (1..20).collect do |level|
  {:lv => level, :exp => curve.exp_by_level(level)}
end

tt curve.level_elems

output_file(records, "_exp_curve1.png")

# レベル2のときに経験値10にするには？

curve = ExpCurve.new(2, 10, 20, 999)
curve.exp_by_level(2)           # => 10

# レベル 21..25 は崖っ縁にしたい場合は？

curve = ExpCurve.new(20, 999, 25, 10000)
curve.exp_by_level(20)          # => 999
curve.exp_by_level(21)          # => 1359
curve.exp_by_level(22)          # => 2439
curve.exp_by_level(23)          # => 4239
curve.exp_by_level(24)          # => 6760
curve.exp_by_level(25)          # => 10000 # !> assigned but unused variable - id

records += (21..25).collect do |level|
  {:lv => level, :exp => curve.exp_by_level(level)}
end

output_file(records, "_exp_curve2.png")

tt curve.level_elems
tt curve.exp_elems
# >> +----+-----+
# >> | lv | exp |
# >> +----+-----+
# >> |  1 |   0 |
# >> |  2 |   3 |
# >> |  3 |  11 |
# >> |  4 |  25 |
# >> |  5 |  44 |
# >> |  6 |  69 |
# >> |  7 | 100 |
# >> |  8 | 136 |
# >> |  9 | 177 |
# >> | 10 | 224 |
# >> | 11 | 277 |
# >> | 12 | 335 |
# >> | 13 | 398 |
# >> | 14 | 468 |
# >> | 15 | 542 |
# >> | 16 | 623 |
# >> | 17 | 708 |
# >> | 18 | 800 |
# >> | 19 | 897 |
# >> | 20 | 999 |
# >> +----+-----+
# >> writing this to gnuplot:
# >> set terminal png font 'Ricty-Bold.ttf'
# >> set output "_exp_curve1.png"
# >> set title "経験値曲線"
# >> set xlabel "Level"
# >> set xtics 1
# >> set ylabel "累計経験値"
# >> set xrange [0:*]
# >> set yrange [0:*]
# >> set label 1 center at first 1, 0 '0'
# >> set label 2 center at first 2, 3 '3'
# >> set label 3 center at first 3, 11 '11'
# >> set label 4 center at first 4, 25 '25'
# >> set label 5 center at first 5, 44 '44'
# >> set label 6 center at first 6, 69 '69'
# >> set label 7 center at first 7, 100 '100'
# >> set label 8 center at first 8, 136 '136'
# >> set label 9 center at first 9, 177 '177'
# >> set label 10 center at first 10, 224 '224'
# >> set label 11 center at first 11, 277 '277'
# >> set label 12 center at first 12, 335 '335'
# >> set label 13 center at first 13, 398 '398'
# >> set label 14 center at first 14, 468 '468'
# >> set label 15 center at first 15, 542 '542'
# >> set label 16 center at first 16, 623 '623'
# >> set label 17 center at first 17, 708 '708'
# >> set label 18 center at first 18, 800 '800'
# >> set label 19 center at first 19, 897 '897'
# >> set label 20 center at first 20, 999 '999'
# >> 
# >> writing this to gnuplot:
# >> set terminal png font 'Ricty-Bold.ttf'
# >> set output "_exp_curve2.png"
# >> set title "経験値曲線"
# >> set xlabel "Level"
# >> set xtics 1
# >> set ylabel "累計経験値"
# >> set xrange [0:*]
# >> set yrange [0:*]
# >> set label 1 center at first 1, 0 '0'
# >> set label 2 center at first 2, 3 '3'
# >> set label 3 center at first 3, 11 '11'
# >> set label 4 center at first 4, 25 '25'
# >> set label 5 center at first 5, 44 '44'
# >> set label 6 center at first 6, 69 '69'
# >> set label 7 center at first 7, 100 '100'
# >> set label 8 center at first 8, 136 '136'
# >> set label 9 center at first 9, 177 '177'
# >> set label 10 center at first 10, 224 '224'
# >> set label 11 center at first 11, 277 '277'
# >> set label 12 center at first 12, 335 '335'
# >> set label 13 center at first 13, 398 '398'
# >> set label 14 center at first 14, 468 '468'
# >> set label 15 center at first 15, 542 '542'
# >> set label 16 center at first 16, 623 '623'
# >> set label 17 center at first 17, 708 '708'
# >> set label 18 center at first 18, 800 '800'
# >> set label 19 center at first 19, 897 '897'
# >> set label 20 center at first 20, 999 '999'
# >> set label 21 center at first 21, 1359 '1359'
# >> set label 22 center at first 22, 2439 '2439'
# >> set label 23 center at first 23, 4239 '4239'
# >> set label 24 center at first 24, 6760 '6760'
# >> set label 25 center at first 25, 10000 '10000'
# >> 
# >> +----+-------+
# >> | lv | exp   |
# >> +----+-------+
# >> | 20 |   999 |
# >> | 21 |  1359 |
# >> | 22 |  2439 |
# >> | 23 |  4239 |
# >> | 24 |  6760 |
# >> | 25 | 10000 |
# >> +----+-------+
# >> +-------+------+
# >> | lv    | exp  |
# >> +-------+------+
# >> |  20.0 |  999 |
# >> | 20.83 | 1249 |
# >> | 21.18 | 1499 |
# >> | 21.44 | 1749 |
# >> | 21.67 | 1999 |
# >> | 21.86 | 2249 |
# >> | 22.04 | 2499 |
# >> |  22.2 | 2749 |
# >> | 22.36 | 2999 |
# >> |  22.5 | 3249 |
# >> | 22.64 | 3499 |
# >> | 22.76 | 3749 |
# >> | 22.89 | 3999 |
# >> |  23.0 | 4249 |
# >> | 23.12 | 4499 |
# >> | 23.23 | 4749 |
# >> | 23.33 | 4999 |
# >> | 23.44 | 5249 |
# >> | 23.54 | 5499 |
# >> | 23.63 | 5749 |
# >> | 23.73 | 5999 |
# >> | 23.82 | 6249 |
# >> | 23.91 | 6499 |
# >> |  24.0 | 6749 |
# >> | 24.08 | 6999 |
# >> | 24.17 | 7249 |
# >> | 24.25 | 7499 |
# >> | 24.33 | 7749 |
# >> | 24.41 | 7999 |
# >> | 24.49 | 8249 |
# >> | 24.56 | 8499 |
# >> | 24.64 | 8749 |
# >> | 24.71 | 8999 |
# >> | 24.79 | 9249 |
# >> | 24.86 | 9499 |
# >> | 24.93 | 9749 |
# >> |  25.0 | 9999 |
# >> +-------+------+
