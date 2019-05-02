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

    def pdf_y( y )
      mb = @pdf.margin_box
      mb.top - y
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
      font_size = opts[:font_size] || [pr.w.to_f/w ,pr.h.to_f/h].min * 0.95

      @pdf.bounding_box([pr.x, pr.bottom], width:pr.w, height:pr.h ) do
        @pdf.transparent(1) { @pdf.stroke_bounds }
      end

      @pdf.text_box(
        t,
        at:[pr.x, pr.bottom],
        width:pr.w,
        height:pr.h,
        align: opts[:align] || :center,
        valign: opts[:valign] || :center,
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

    def stroke_rect(rect)
      @pdf.save_graphics_state do
        pr = pdf_rect(rect)
        @pdf.stroke{
          @pdf.rectangle( [pr.x, pr.bottom], pr.w, pr.h )
        }
      end
    end

    def draw_samesize_texts( rects, texts, align: :center )
      @pdf.save_graphics_state do
        size = texts.zip(rects).map{ |txt,rc|
          w = @pdf.width_of(txt, size:1)
          h = @pdf.height_of(txt, size:1)
          [rc.w.to_f/w, rc.h.to_f/h].min
        }.min
        texts.zip(rects).each do |txt, rc|
          text( txt, rc, font_size:size, align:align )
        end
      end
    end

    def horizontal_line( left, right, y, style: :solid, color:"000", color2:nil )
      @pdf.save_graphics_state do
        case style
        when :solid
          unless color.nil?
            @pdf.stroke_color pdf_color(color)
            @pdf.stroke_horizontal_line(left, right, at:pdf_y(y))
          end
        when :dash
          unless color.nil?
            @pdf.dash([2,2])
            @pdf.stroke_color pdf_color(color)
            @pdf.stroke_horizontal_line(left, right, at:pdf_y(y))
          end
          unless color2.nil?
            @pdf.dash([2,2], phase:2)
            @pdf.stroke_color pdf_color(color2)
            @pdf.stroke_horizontal_line(left, right, at:pdf_y(y))
          end
        else
          raise Errors::InternalError, "unexpected line style: #{style.inspect}"
        end
      end
    end
  end
end
