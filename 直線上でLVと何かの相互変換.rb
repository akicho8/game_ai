# -*- coding: utf-8 -*-
#
# 一次関数を使ったXYの相互変換
#
#   レベル1..99が何か0..9999に対応する一次関数でレベル30のときの何か？ またその逆は？
#
#     curve = LinearCurve.create(1..99, 0..9999)
#     v = curve.y_by_x(30)        # => 875.5892336526448
#     curve.x_by_y(v)             # => 30.0
#

require "bundler/setup"

class LinearCurve < Struct.new(:x0, :y0, :x1, :y1)
  def self.create(x_range, y_range)
    new(x_range.min, y_range.min, x_range.max, y_range.max)
  end

  def y_by_x(x)
    (y1 - y0).to_f * (x - x0) / (x1 - x0) + y0
  end

  def x_by_y(y)
    ((y - y0) * (x1 - x0)).to_f / (y1 - y0) + x0
  end
end

if $0 == __FILE__
  require "rain_table"
  require "gnuplot"

  def output_file(records, filename)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal "png font 'Ricty-Bold.ttf'"
        plot.output filename
        # plot.title "レベルに比例する何か"
        plot.xlabel "Level"
        # plot.xtics 1
        plot.ylabel "何か"
        # plot.xrange "[0:*]"
        # plot.yrange "[0:*]"
        records.each.with_index{|e, i|
          plot.label "#{i.next} center at first #{e[:lv]}, #{e[:exp]} '#{e[:exp]}'"
        }
        plot.data << Gnuplot::DataSet.new([records.collect{|e|e[:lv]}, records.collect{|e|e[:exp]}]) do |ds|
          ds.with = "linespoints pointtype 7 pointsize 0.5"
          ds.notitle
        end
      end
    end
  end

  curve = LinearCurve.create(1..20, 300..2400)
  y = curve.y_by_x(15)                # => 1847.3684210526317
  curve.x_by_y(y)                     # => 15.0

  records = (1..20).collect do |level|
    {:lv => level, :exp => curve.y_by_x(level).round(2)}
  end

  output_file(records, "_linear_curve.png")


  
  
  
  
  
  
  
  
end
# >> writing this to gnuplot:
# >> set terminal png font 'Ricty-Bold.ttf'
# >> set output "_linear_curve.png"
# >> set xlabel "Level"
# >> set ylabel "何か"
# >> set label 1 center at first 1, 300.0 '300.0'
# >> set label 2 center at first 2, 410.53 '410.53'
# >> set label 3 center at first 3, 521.05 '521.05'
# >> set label 4 center at first 4, 631.58 '631.58'
# >> set label 5 center at first 5, 742.11 '742.11'
# >> set label 6 center at first 6, 852.63 '852.63'
# >> set label 7 center at first 7, 963.16 '963.16'
# >> set label 8 center at first 8, 1073.68 '1073.68'
# >> set label 9 center at first 9, 1184.21 '1184.21'
# >> set label 10 center at first 10, 1294.74 '1294.74'
# >> set label 11 center at first 11, 1405.26 '1405.26'
# >> set label 12 center at first 12, 1515.79 '1515.79'
# >> set label 13 center at first 13, 1626.32 '1626.32'
# >> set label 14 center at first 14, 1736.84 '1736.84'
# >> set label 15 center at first 15, 1847.37 '1847.37'
# >> set label 16 center at first 16, 1957.89 '1957.89'
# >> set label 17 center at first 17, 2068.42 '2068.42'
# >> set label 18 center at first 18, 2178.95 '2178.95'
# >> set label 19 center at first 19, 2289.47 '2289.47'
# >> set label 20 center at first 20, 2400.0 '2400.0'
# >> 
