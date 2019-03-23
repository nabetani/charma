# frozen_string_literal: true

module Charma
  class Chart
    def stroke_rect( pdf, rect )
      pdf.stroke{
        pdf.rectangle( [rect.x, rect.y], rect.w, rect.h )
      }
    end

    def fill_rect( pdf, rect, col )
      pdf.save_graphics_state do
        pdf.fill{
          pdf.fill_color( col )
          pdf.rectangle( [rect.x, rect.y], rect.w, rect.h )
        }
      end
    end

    def draw_text( pdf, rect, text, opts = {} )
      pdf.text_box( text,
        at:rect.topleft,
        width:rect.w,
        height:rect.h,
        align: (opts[:align] || :center),
        valign: (opts[:valign] || :center),
        size: (opts[:size] || rect.h),
        overflow: :shrink_to_fit )
    end

    def colors(n)
      f = ->(t0){
        t = t0 % 3
        v = case t
        when 0..1 then t
        when 1..2 then 2-t
        else 0
        end
        "%02x" % (v**0.5*255).round
      }
      Array.new(n){ |i|
        t = i*3.0/n
        [f[t],f[t+1],f[t+2]].join
      }
    end

    def draw_samesize_texts( pdf, rects, texts, opts={} )
      pdf.save_graphics_state do
        size = texts.zip(rects).map{ |txt,rc|
          w = pdf.width_of(txt, size:1)
          h = pdf.height_of(txt, size:1)
          [rc.w.to_f/w ,rc.h.to_f/h].min
        }.min
        texts.zip(rects).each do |txt, rc|
          draw_text( pdf, rc, txt, size:size, **opts )
        end
      end
    end

    def render_rottext( pdf, rect, text )
      pdf.rotate(90, origin: rect.center) do
        rc = rect.rot90
        w = pdf.width_of(text, size:1)
        h = pdf.height_of(text, size:1)
        size = [rc.w.to_f/w ,rc.h.to_f/h].min
        pdf.draw_text( text, size:size, at:rc.bottomleft )
      end
    end
  end
end
