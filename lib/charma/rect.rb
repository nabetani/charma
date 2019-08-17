# frozen_string_literal: true

module Charma

  # 矩形
  Rect = Struct.new( :x, :y, :w, :h ) do

    # 垂直(上下)に分割する
    # @param[ Array<Numeric> ] rel_hs 相対的な高さのリスト
    def vsplit( *rel_hs )
      rel_sum = rel_hs.sum
      abs_y = y.to_f
      rel_hs.map{ |rel_h|
        abs_h = rel_h.to_f * h / rel_sum
        rc = Rect.new( x, abs_y, w, abs_h )
        abs_y += abs_h
        rc
      }
    end

    # 水平(左右)に分割する
    # @param [Array<Numeric>] rel_ws 相対的な幅のリスト
    def hsplit( *rel_ws )
      rel_sum = rel_ws.sum
      abs_x = x.to_f
      rel_ws.map{ |rel_w|
        abs_w = rel_w.to_f * w / rel_sum
        rc = Rect.new( abs_x, y, abs_w, h )
        abs_x += abs_w
        rc
      }
    end

    # 自分を縮小した矩形を返す。中心を維持して、上下左右から同じ長さを減じる。
    # @param [Numeric] ratio 縮小する割合。0.1 を指定すると、上下左右から 10% 減らして、80%✕80% の大きさになる。
    def reduce( ratio )
      len = [w,h].min*ratio/2
      Rect.new( x+len, y+len, w-len*2, h-len*2 )
    end

    # 自分を左右方向に縮小した矩形を返す。中心を維持して、左右から同じ長さを減じる。
    # @param [Numeric] ratio 縮小する割合。0.1 を指定すると、左右から 10% 減らす。
    def reduce_h( ratio )
      len = w*ratio/2
      Rect.new( x+len, y, w-len*2, h )
    end

    # 中心の座標。x, y の順
    def center
      [cx, cy]
    end

    # 中心の x 座標
    def cx
      x+w/2.0
    end

    # 中心の y 座標
    def cy
      y+h/2.0
    end

    # 自分を90度回した矩形。回転の中心は矩形の中心。
    def rot
      cx, cy = center
      Rect.new( cx-h/2, cy-w/2, h, w )
    end

    # 右端の座標
    def right
      x+w
    end

    # 下端の座標
    def bottom
      y+h
    end
  end
end
