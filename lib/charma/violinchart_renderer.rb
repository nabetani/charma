# frozen_string_literal: true

module Charma
  # バイオリンチャートを描画する
  class ViolinChartRenderer < ChartRenderer

    # 描画オブジェクトを生成する
    def initialize( chart, canvas, area )
      super
    end

    # x_ticks 領域があるかどうか
    def x_ticks_area?
      !! @chart[:x_ticks]
    end

    # x_marks 領域があるかどうか
    def x_marks_area?
      false
    end

    # y の範囲を計算する
    # ※ 対数目盛に対応する
    # y2 には対応しない。
    def calc_yrange
      if @chart[:y_range]
        return @chart[:y_range]
      end
      v = @chart[:series].flat_map{ |s|
        s[:y]&.map{ |vals| 
          vals.flatten.map{ |val|
            scale_value( :y, val )
          }
        }
      }.flatten.compact.minmax
      diff = v[1]-v[0]
      ex = diff==0 ? 1 : diff*0.5/(@chart.bins-1)
      mm=[v[0]-ex, v[1]+ex]
      mm.map{ |e| unscale_value(:y, e) }
    end

    # 色を生成する。
    # 系列が複数の場合は系列ごとに同じ色。
    # 系列が一つの場合はすべて別の色
    # TODO: barchart_renderer に同じメソッドがある
    def create_colors
      scount = @chart[:series].size
      ssize = @chart[:series].map{ |s| (s[:y]||s[:y2]).size }.max
      if scount==1
        seq_colors(ssize).map{ |e| [e] }
      else
        [seq_colors(scount)] * ssize
      end
    end

    # y の値のリストのリストから、ヒストグラムを作る
    def ratios_from_values( yv, bins, yrange )
      diff = scale_value(:y, yrange[1])-scale_value(:y, yrange[0] )
      y0 = scale_value(:y, yrange[0])
      boundaries = Array.new(bins+1){ |ix|
        y0 + diff * ix.to_f / bins
      }
      y_ranges = boundaries.each_cons(2).map{ |lo, hi|
        (lo...hi)
      }
      counts = yv.map{ |yyy|
        yyy.map{ |yy|
          y_ranges.map{ |r| yy.count{ |y| r.include?(scale_value(:y, y)) } }
        }
      }
      max = counts.flatten.max
      counts.map{ |ccc|
        ccc.map{ |cc|
          cc.map{ |c| c.to_f/max }
        }
      }
    end

    def draw_rectgroup(g, col, w0)
      w = [w0*3e-2, g.first.h/3.0].min
      lefts=[]
      rights=[]
      g.each do |rc|
        lefts += [[rc.x,rc.bottom], [rc.x, rc.y]]
        rights += [[rc.right,rc.bottom], [rc.right, rc.y]]
      end
      points = lefts.reverse+rights
      min, max = points.map(&:first).minmax
      @canvas.stroke_polygon( points, color:"000", width:w )
      @canvas.fill_polygon( points, col )
    end

    def draw_violins(rs, rc0, cols, yrange)
      rcs = rc0.hsplit(*([1]*rs.size)).map{ |rc| rc.reduce_h(0.1) }
      rcs.zip(rs, cols).each do |rc, rr, col|
        boards = rc.vsplit(*([1]*rr.size)).reverse
        rects = boards.zip(rr).map do |board, r|
          if r.zero?
            nil
          else
            w = board.w * r
            Rect.new( board.cx - w/2, board.y, w, board.h )
          end
        end
        Charma.split_enumerable( rects, &:nil? ).each do |g|
          draw_rectgroup(g, col, rc.w) unless g.empty?
        end
      end
    end

    # チャートを描画する
    def render_chart
      yrange = calc_yrange
      y_values = @chart[:series].map{ |s| s[:y] }.transpose
      violin_areas = @areas.chart.hsplit(*([1]*y_values.size))
      y_ratios = ratios_from_values( y_values, @chart.bins, yrange )
      y_ratios.zip(violin_areas, create_colors).each do |rs, rc0, cols|
        rc = rc0.reduce_h(0.1)
        @canvas.fill_rect(rc, "eee" )
        draw_violins(rs, rc, cols, yrange)
      end
      y_ticks = tick_values(:y, yrange)
      draw_y_grid(:y, @areas.chart, yrange, y_ticks)
      draw_y_ticks(:y, @areas.y_ticks, yrange, y_ticks)
      draw_y_marks(:y, @areas.y_marks, yrange, y_ticks)
      if @chart.y2?
        y2_ticks = tick_values(:y2, y2range)
        draw_y_ticks(:y2, @areas.y2_ticks, y2range, y2_ticks)
        draw_y_marks(:y2, @areas.y2_marks, y2range, y2_ticks)
      end
      draw_x_tick_texts(@areas.x_ticks, @chart[:x_ticks]) if @chart[:x_ticks]
      if bottom_legend?
        scount = @chart[:series].size
        names = @chart[:series].map{ |e| e[:name] }
        draw_bottom_regend(@areas.legend, names, seq_colors(scount))
      end
      @canvas.stroke_rect(@areas.chart)
    end
  end
end
