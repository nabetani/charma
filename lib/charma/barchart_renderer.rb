# frozen_string_literal: true

module Charma
  # 棒グラフを描画する
  class BarChartRenderer < ChartRenderer

    # 描画オブジェクトを生成する
    def initialize( chart, canvas, area )
      super
    end

    def make_simple_range( r )
      if r && r.min<0 && r.max<=0
        [-1,0]
      else
        [0,1]
      end
    end

    # y と y2 の範囲を計算する
    # 返戻値の第一要素が yの範囲。第二要素が y2の範囲。y2 がない場合はnil
    # ※ 対数目盛に対応しないので、scale / unscale 不要
    # ※ y と y2 の y==0 の描画座標が等しくなるようにする
    def calc_yranges
      vals = %i(y y2).map{ |sym|
        v = @chart[:series].map{ |s| s[sym] }.flatten.compact
        v.empty? ? nil : (v+[0]).minmax
      }
      # 1.1 にすると、0〜1 のグラフの上端の目盛りが 1.1 になってしまうので、1.099 にする
      expansion = 1.099

      # ゼロ除算対策
      vals[0] = make_simple_range(vals[1]) if vals[0]==[0,0]
      vals[1] = make_simple_range(vals[0]) if vals[1]==[0,0]
      unless vals[1]
        return [ vals[0].map{ |e| e*expansion }, nil ]
      end
      lens = vals.map{ |e| e.max - e.min }
      ratio = lens[0].to_f / lens[1]
      valranges = vals.zip( [1,ratio] ).map{ |v,r| v.map{ |e| e*r } }
      range = valranges.flatten.minmax.map{ |e| e*expansion }
      area_ranges = [1,1/ratio].map{ |r| range.map{ |e| e*r } }
    end
    
    # 棒を描画する
    # ys :: y の値のリスト。ys[0] が最初の系列の y の値。
    # rc :: 一連のバーを含む矩形
    # cols :: 色のリスト。cols[0] が最初の系列の色。
    # yrange :: 第一y軸の値の範囲。
    # y2range :: 第二y軸の値の範囲。
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
      yrange, y2range = calc_yranges
      y_values = @chart[:series].map{ |s| s[:y]||s[:y2] }.compact.transpose
      bar_areas = @areas.chart.hsplit(*Array.new(y_values.size,1))
      y_values.zip(bar_areas, create_colors).each do |ys, rc, cols|
        draw_bars(ys, rc, cols, yrange, y2range)
      end
      y_ticks = tick_values(:y, yrange)
      draw_y_grid(@areas.chart, yrange, y_ticks)
      draw_y_ticks(@areas.y_ticks, yrange, y_ticks)
      draw_y_marks(@areas.y_marks, yrange, y_ticks)
      if @chart.y2?
        y2_ticks = tick_values(:y2, y2range)
        draw_y_ticks(@areas.y2_ticks, y2range, y2_ticks)
        draw_y_marks(@areas.y2_marks, y2range, y2_ticks)
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
