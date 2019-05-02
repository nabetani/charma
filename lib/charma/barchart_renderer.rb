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

    def draw_bars( ys, rc, cols, yrange )
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

    def create_colors
      scount = @chart[:series].size
      ssize = @chart[:series].map{ |s| s[:y].size }.max
      if scount==1
        seq_colors(ssize).map{ |e| [e] }
      else
        [seq_colors(scount)] * ssize
      end
    end

    def render_chart
      yrange = calc_yrange
      y_values = @chart[:series].map{ |s| s[:y] }.transpose
      bar_areas = @areas.chart.hsplit(*Array.new(y_values.size,1))
      y_values.zip(bar_areas, create_colors).each do |ys, rc, cols|
        draw_bars(ys, rc, cols, yrange)
      end
      y_ticks = tick_values(:y, yrange)
      draw_y_grid(@areas.chart, yrange, y_ticks)
      @canvas.stroke_rect(@areas.chart)
    end
  end
end
