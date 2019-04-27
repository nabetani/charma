# frozen_string_literal: true

module Charma
  class PDFCanvas
    def initialize( pdf )
      @pdf = pdf
    end

    def new_page( page )
      # TODO: set page size
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

    def text( t, rect, opts = {} )
      pr = pdf_rect(rect)
      @pdf.bounding_box([pr.x, pr.bottom], width:pr.w, height:pr.h ) do
        @pdf.transparent(1) { @pdf.stroke_bounds }
        @pdf.font_size 16
      end
      @pdf.text_box( t,
        at:[pr.x, pr.bottom],
        width:pr.w,
        height:pr.h,
        align: :center,
        valign: :center,
        size: rect.h*2,
        overflow: :shrink_to_fit )



    end
  end
end
