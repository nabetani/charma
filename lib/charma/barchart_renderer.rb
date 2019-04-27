# frozen_string_literal: true

module Charma
  class BarChartRenderer < ChartRenderer
    def initialize( chart, canvas, area )
      super
    end

    def calc_yrange
      yvals = @chart[:series].map{ |s| s[:y] }.flatten.compact
      min, max = yvals.minmax
      ymin = [0, min * 1.1].min
      ymax = [0, max * 1.1].max
      [ ymin, ymax ]
    end

    def draw_bar( ys, rc, cols, yrange )
      ratio = 0.75
      _, bars, = rc.hsplit( (1-ratio)/2, ratio, (1-ratio)/2 )
      bar_rects = bars.hsplit(*Array.new(ys.size,1))
      bar_rects.zip(ys, cols) do |bar, y, col|
        ay = abs_y_positoin(y, bar, yrange)
        zero = abs_y_positoin(0, bar, yrange)
        t, b = [ ay, zero ].minmax
        rc = Rect.new( bar.x, t, bar.w, b-t )
        @canvas.fill_rect( rc, col )
      end
    end

    def render_chart
      yrange = calc_yrange
      y_values = @chart[:series].map{ |s| s[:y] }.transpose
      bar_areas = @areas.chart.hsplit(*Array.new(y_values.size,1))
      y_values.zip(bar_areas).each do |ys, rc|
        cols = %w(f00 00f)
        draw_bar(ys, rc, cols, yrange)
      end
    end
  end
end
