# frozen_string_literal: true

module Charma
  # 棒グラフを描画する
  class ScatterChartRenderer < ChartRenderer

    # 描画オブジェクトを生成する
    def initialize( chart, canvas, area )
      super
    end

    def expand_range( axis, range, width )
      min, max = range.minmax
      xmin = min-width
      xmax = max+width
      ignore_zero_pos = scale_type(axis)==:log10
      if ignore_zero_pos
        [xmin, xmax]
      elsif 0<xmin
        [xmin, xmax]
      elsif 0<=min
        [0, xmax]
      elsif 0<max
        [xmin, xmax]
      elsif 0<=xmax
        [xmin, 0]
      else
        [xmin, xmax]
      end
    end

    # x の範囲を計算する
    # 返戻値は 1要素の配列。第一要素が xの範囲。
    # ※ 対数目盛に対応する
    def calc_xranges
      range = @chart[:series].flat_map{ |s|
        %i( xy xy2 ).flat_map{ |sym|
          s[sym]&.map{ |xy| scale_value( :x, xy[0] ) }
        }
      }.compact.minmax
      range = expand_range(:x, range, 1) if range[0]==range[1] # ゼロ除算対策
      # 0.1 にすると、0〜1 のグラフの上端の目盛りが 1.1 になってしまうので、0.099 にする
      expansion = 0.099
      diff = range[1]-range[0]
      axis = :x
      r = expand_range(axis, range, diff*expansion).map{ |e| unscale_value( axis, e ) }
      [r]
    end

    # y と y2 の範囲を計算する
    # 返戻値の第一要素が yの範囲。第二要素が y2の範囲。y2 がない場合はnil
    # ※ 対数目盛に対応する
    # ※ y と y2 の y==0 の描画座標が等しくなるようにはしない
    def calc_yranges
      ranges = %i(xy xy2).map{ |sym|
        axis = sym==:xy ? :y : :y2
        v = @chart[:series].flat_map{ |s| 
          s[sym]&.map{ |xy| scale_value( axis, xy[1] ) }
        }.compact
        if v.empty?
          nil
        else
          candidate = v.minmax
          if candidate[0]==candidate[1]
            expand_range( axis, v, 1 ) # ゼロ除算対策
          else
            v.minmax
          end
        end
      }
      # 0.1 にすると、0〜1 のグラフの上端の目盛りが 1.1 になってしまうので、0.099 にする
      expansion = 0.099
      ranges.zip(%i(y y2)).map do |v, axis|
        if v
          diff = v[1]-v[0]
          expand_range(axis, v, diff*expansion).map{ |e| unscale_value( axis, e ) }
        end
      end
    end

    def x_ticks_area?
      true
    end

    def x_marks_area?
      true
    end

    def draw_points( area, xrange, y1range, y2range )
      cols = seq_colors(@chart[:series].size)
      radius = 10
      @chart[:series].zip(cols).each do |s,col|
        positions, yaxis = s[:xy] ? [s[:xy], :y] : [s[:xy2], :y2]
        yrange = yaxis==:y ? y1range : y2range
        positions.each do |pos|
          ax = abs_x_position(pos[0], area, xrange)
          ay = abs_y_position(pos[1], area, yrange)
          @canvas.fill_circle( ax, ay, radius, col )
        end
      end
    end

    # チャートを描画する
    def render_chart
      yrange, y2range = calc_yranges
      xrange, = calc_xranges
      y_ticks = tick_values(:y, yrange)
      x_ticks = tick_values(:x, xrange)
      draw_y_grid(@areas.chart, yrange, y_ticks)
      draw_y_ticks(@areas.y_ticks, yrange, y_ticks)
      draw_y_marks(@areas.y_marks, yrange, y_ticks)

      draw_x_grid(@areas.chart, xrange, x_ticks)
      draw_x_ticks(@areas.x_ticks, xrange, x_ticks)
      draw_x_marks(@areas.x_marks, xrange, x_ticks)
      if bottom_legend?
        scount = @chart[:series].size
        names = @chart[:series].map{ |e| e[:name] }
        draw_bottom_regend(@areas.legend, names, seq_colors(scount))
      end
      draw_points( @areas.chart, xrange, yrange, y2range )
      @canvas.stroke_rect(@areas.chart)
    end
  end
end
