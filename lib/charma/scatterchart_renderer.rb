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

    # y と y2 の範囲を計算する
    # 返戻値の第一要素が yの範囲。第二要素が y2の範囲。y2 がない場合はnil
    # ※ 対数目盛に対応する
    # ※ y と y2 の y==0 の描画座標が等しくなるようにはしない
    def calc_yranges
      vals = %i(xy xy2).map{ |sym|
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
      vals.zip(%i(y y2)).map do |v, axis|
        if v
          diff = v[1]-v[0]
          expand_range(axis, v, diff*expansion).map{ |e| unscale_value( axis, e ) }
        end
      end
    end

  end
end
