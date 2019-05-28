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
  end
end
