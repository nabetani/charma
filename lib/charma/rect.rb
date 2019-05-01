# frozen_string_literal: true

module Charma
  Rect = Struct.new( :x, :y, :w, :h ) do
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

    def center
      [cx, cy]
    end

    def cx
      x+w/2.0
    end

    def cy
      y+h/2.0
    end

    def rot
      cx, cy = center
      Rect.new( cx-h/2, cy-w/2, h, w )
    end

    def right
      x+w
    end

    def bottom
      y+h
    end
  end
end
