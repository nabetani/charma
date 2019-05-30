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

    # TODO: 同じメソッドが scatterchart_renderer にある
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

    # y と y2 の範囲を計算する
    # 返戻値の第一要素が yの範囲。第二要素が y2の範囲。y2 がない場合はnil
    # ※ 対数目盛に対応する
    # ※ y と y2 の y==0 の描画座標が等しくなるようにはしない
    def calc_yranges
      yrange, y2range = %i(y y2).map{ |sym|
        v = @chart[:series].flat_map{ |s|
          s[sym]&.map{ |vals| 
            vals.flatten.map{ |val|
              scale_value( sym, val )
            }
          }
        }.flatten.compact
        if v.empty?
          nil
        else
          candidate = v.minmax
          mm = if candidate[0]==candidate[1]
            expand_range( sym, candidate, 1 ) # ゼロ除算対策
          else
            diff = candidate[1]-candidate[0]
            expand_range( sym, candidate, diff*0.099 )
          end
          mm.map{ |e| unscale_value(sym, e) }
        end
      }
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
    def ratios_from_values( yv, bins, yrange, y2range )
      y_ranges = Array.new(bins){ |ix|
        lo = yrange[0] + ( yrange[1]-yrange[0] ) * ix.to_f / bins
        hi = yrange[0] + ( yrange[1]-yrange[0] ) * (ix+1).to_f / bins
        (lo...hi)
      }
      counts = yv.map{ |yyy|
        yyy.map{ |yy|
          y_ranges.map{ |r| yy.count{ |y| r.include?(y) } }
        }
      }
      max = counts.flatten.max
      counts.map{ |ccc|
        ccc.map{ |cc|
          cc.map{ |c| c.to_f/max }
        }
      }
    end

    def draw_violins(rs, rc0, cols, yrange, y2range)
      rcs = rc0.hsplit(*([1]*rs.size))
      rcs.zip(rs).each do |rc, rr|
        boards = rc.vsplit(*([1]*rr.size)).reverse
        boards.zip(rr).each do |board, r|
          next if r.zero?
          w = board.w * r
          cell = Rect.new( board.cx - w/2, board.y, w, board.h )
          @canvas.fill_rect( cell, "f00" )
        end
      end
    end

    # チャートを描画する
    def render_chart
      yrange, y2range = calc_yranges
      y_values = @chart[:series].map{ |s| s[:y]||s[:y2] }.compact.transpose
      violin_areas = @areas.chart.hsplit(*([1]*y_values.size))
      bins = 10 # TODO: チャートから取ってくる
      y_ratios = ratios_from_values( y_values, bins, yrange, y2range )
      y_ratios.zip(violin_areas, create_colors).each do |rs, rc, cols|
        @canvas.stroke_rect(rc)
        draw_violins(rs, rc, cols, yrange, y2range)
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
