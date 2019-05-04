# frozen_string_literal: true

module Charma
  # 棒グラフを描画する
  class BarChartRenderer < ChartRenderer

    # 描画オブジェクトを生成する
    def initialize( chart, canvas, area )
      super
    end

    # y の範囲を計算する
    def calc_yrange(axis)
      yvals = @chart[:series].map{ |s| s[axis] }.flatten.compact
      min, max = yvals.minmax.map{ |e| scale_value( axis, e ) }
      ymin = [0, min * 1.1].min
      ymax = [0, max * 1.1].max
      [ ymin, ymax ].map{ |e| unscale_value(axis, e) }
    end
    
    # 棒を描画する
    def draw_bars( ys, rc, cols, yrange, y2range )
      ratio = 0.75
      _, bars, = rc.hsplit( (1-ratio)/2, ratio, (1-ratio)/2 )
      bar_rects = bars.hsplit(*Array.new(ys.size,1))
      bar_rects.zip(ys, cols).each.with_index do |(bar, y, col),ix|
        axis = @chart[:series][ix][:y] ? :y : :y2
        range = axis==:y ? yrange : y2range
        ay = abs_y_position(y, bar, range)
        zero = abs_y_position(0, bar, range)
        t, b = [ ay, zero ].minmax
        rc = Rect.new( bar.x, t, bar.w, b-t )
        @canvas.fill_rect( rc, col )
      end
    end

    # 色を生成する。
    # 系列が複数の場合は系列ごとに同じ色。
    # 系列が一つの場合はすべて別の色
    def create_colors
      scount = @chart[:series].size
      ssize = @chart[:series].map{ |s| (s[:y]||s[:y2]).size }.max
      if scount==1
        seq_colors(ssize).map{ |e| [e] }
      else
        [seq_colors(scount)] * ssize
      end
    end

    # チャートを描画する
    def render_chart
      yrange = calc_yrange(:y)
      y2range = calc_yrange(:y2)
      y_values = @chart[:series].map{ |s| s[:y]||s[:y2] }.compact.transpose
      bar_areas = @areas.chart.hsplit(*Array.new(y_values.size,1))
      y_values.zip(bar_areas, create_colors).each do |ys, rc, cols|
        draw_bars(ys, rc, cols, yrange, y2range)
      end
      y_ticks = tick_values(:y, yrange)
      draw_y_grid(@areas.chart, yrange, y_ticks)
      draw_y_ticks(@areas.y_ticks, yrange, y_ticks)
      if @chart.y2?
        y2_ticks = tick_values(:y2, y2range)
        draw_y_ticks(@areas.y2_ticks, y2range, y2_ticks)
      end
      draw_x_ticks(@areas.x_ticks, @chart[:x_ticks]) if @chart[:x_ticks]
      if bottom_legend?
        scount = @chart[:series].size
        names = @chart[:series].map{ |e| e[:name] }
        draw_bottom_regend(@areas.legend, names, seq_colors(scount))
      end
      @canvas.stroke_rect(@areas.chart)
    end
  end
end
