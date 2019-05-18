# frozen_string_literal: true

module Charma
  # 棒グラフを描画する
  class ScatterChartRenderer < ChartRenderer

    # 描画オブジェクトを生成する
    def initialize( chart, canvas, area )
      super
    end

    def expand_range( range, width )
      min, max = range.minmax
      xmin = min-width
      xmax = max+width
      if 0<xmin
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
        v = @chart[:series].flat_map{ |s| 
          s[sym]&.map{ |xy| xy[1] }
        }.compact
        if v.empty?
          nil
        else
          candidate = v.minmax
          if candidate[0]==candidate[1]
            expand_range( v, 1) # ゼロ除算対策
          else
            v.minmax
          end
        end
      }
      # 0.1 にすると、0〜1 のグラフの上端の目盛りが 1.1 になってしまうので、0.099 にする
      expansion = 0.099
      vals.map do |v|
        if v
          diff = v[1]-v[0]
          expand_range(v, diff*expansion)
        end # else nil
      end
    end

  end
end
