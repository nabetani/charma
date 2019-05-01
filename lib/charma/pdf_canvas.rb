# frozen_string_literal: true

module Charma
  class PDFCanvas
    def initialize( pdf )
      @pdf = pdf
    end

    def page_rect
      mb = @pdf.margin_box
      Rect.new(mb.left, mb.height - mb.top, mb.width, mb.height)
    end

    def pdf_rect( rc )
      mb = @pdf.margin_box
      Rect.new(
        rc.x,
        mb.top - rc.y - rc.h,
        rc.w, rc.h
      )
    end

    def rottext( t, rect, angle, opts={} )
      pr = pdf_rect(rect).rot
      @pdf.rotate(angle, origin: pr.center) do
        w = @pdf.width_of(t, size:1)
        h = @pdf.height_of(t, size:1)
        font_size = [pr.w.to_f/w ,pr.h.to_f/h].min
        @pdf.bounding_box([pr.x, pr.bottom], width:pr.w, height:pr.h ) do
          @pdf.transparent(1) { @pdf.stroke_bounds }
        end
        @pdf.text_box(
          t,
          at: [pr.x, pr.bottom],
          width: pr.w,
          height: pr.h,
          align: :center,
          valign: :center,
            size:font_size )
      end
    end

    def text( t, rect, opts = {} )
      pr = pdf_rect(rect)
      w = @pdf.width_of(t, size:1)
      h = @pdf.height_of(t, size:1)
      font_size = [pr.w.to_f/w ,pr.h.to_f/h].min * 0.95

      @pdf.bounding_box([pr.x, pr.bottom], width:pr.w, height:pr.h ) do
        @pdf.transparent(1) { @pdf.stroke_bounds }
      end

      @pdf.text_box(
        t,
        at:[pr.x, pr.bottom],
        width:pr.w,
        height:pr.h,
        align: :center,
        valign: :center,
        size:font_size
      )
    end

    def pdf_color(color)
      case color.size
      when 3
        (0..2).map{ |x| color[x]*2 }.join
      when 6
        color
      else
        raise "#{color.inspect} is not expected color format"
      end
    end

    def fill_rect( rect, color )
      @pdf.save_graphics_state do
        pr = pdf_rect(rect)
        @pdf.fill{
          @pdf.fill_color( pdf_color(color) )
          @pdf.rectangle( [pr.x,  pr.bottom], pr.w, pr.h )
        }
      end
    end
  end
end
