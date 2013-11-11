# -*- coding: utf-8 -*-
#
# 一次関数
#
# (y - p0.y) == ((p1.y - p0.y).to_f / (p1.x - p0.x)) * (x - p0.x)
# y = (p1.y - p0.y).to_f * (x - p0.x) / (p1.x - p0.x) + p0.y
# x = ((y - p0.y) * (p1.x - p0.x)).to_f / (p1.y - p0.y) + p0.x
#

require "bundler/setup"

require "rain_table"
require "gnuplot"

class LinearWay < Struct.new(:x0, :y0, :x1, :y1)
  def y_by_x(x)
    (y1 - y0).to_f * (x - x0) / (x1 - x0) + y0
  end
  def x_by_y(y)
    ((y - y0) * (x1 - x0)).to_f / (y1 - y0) + x0
  end
end

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

curve = LinearWay[1, 300, 20, 2400]
y = curve.y_by_x(15)                # => 145.28571428571428
curve.x_by_y(y)                     # => 15.0

records = (1..20).collect do |level|
  {:lv => level, :exp => curve.y_by_x(level).round(2)}
end

output_file(records, "_linear_curve.png")
# >> writing this to gnuplot:
# >> set terminal png font 'Ricty-Bold.ttf'
# >> set output "_linear_curve.png"
# >> set title "レベルに比例する何か"
# >> set xlabel "Level"
# >> set ylabel "何か"
# >> set xrange [0:*]
# >> set yrange [0:*]
# >> set label 1 center at first 1, 3.0 '3.0'
# >> set label 2 center at first 2, 13.16 '13.16'
# >> set label 3 center at first 3, 23.33 '23.33'
# >> set label 4 center at first 4, 33.49 '33.49'
# >> set label 5 center at first 5, 43.65 '43.65'
# >> set label 6 center at first 6, 53.82 '53.82'
# >> set label 7 center at first 7, 63.98 '63.98'
# >> set label 8 center at first 8, 74.14 '74.14'
# >> set label 9 center at first 9, 84.31 '84.31'
# >> set label 10 center at first 10, 94.47 '94.47'
# >> 
