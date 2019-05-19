# frozen_string_literal: true

class FakeCanvas
  def initialize
    @called = []
  end

  attr_reader( :called )

  def fill_rect( rc, color )
    @called << { method: :fill_rect, args:[ rc, color ] }
  end

  def horizontal_line( left, right, y, style: :solid, color:"000", color2:"fff" )
    @called << { method: :horizontal_line, args:[ left, right, y, style, color, color2 ] }
  end

  def vertical_line( top, bottom, x, style: :solid, color:"000", color2:"fff" )
    @called << { method: :vertical_line, args:[ left, right, x, style, color, color2 ] }
  end

  def stroke_rect(rect)
    @called << { method: :stroke_rect, args:[ rect ] }
  end

  def draw_samesize_texts( rects, texts, align: :center )
    @called << { method: :draw_samesize_texts, args:[ rects, texts, align ] }
  end
end
