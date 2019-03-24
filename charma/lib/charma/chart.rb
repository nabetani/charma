# frozen_string_literal: true

module Charma
  class Chart
    def initialize(opts)
      @opts = opts
    end

    def stroke_rect( pdf, rect )
      pdf.stroke{
        pdf.rectangle( [rect.x, rect.y], rect.w, rect.h )
      }
    end

    def values(sym)
      @opts[:series].map{ |s|
        s[sym].map(&:to_f)
      }
    end

    def bottom_legend?
      has_legend?
    end

    def has_legend?
      @opts[:series].any?{ |s| ! s[:name].nil? }
    end

    def abs_x_positoin(v, rc, xrange)
      (v-xrange[0]) * rc.w / (xrange[1]-xrange[0]) + rc.x
    end

    def abs_y_positoin(v, rc, yrange)
      (v-yrange[0]) * rc.h / (yrange[1]-yrange[0]) + rc.bottom
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
      case n
      when 0, 1
        return ["666666"]
      else
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
          t = i*3.0/n+0.5
          [f[t],f[t+1],f[t+2]].join
        }
      end
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

    def render_legend( pdf, rect )
      names = @opts[:series].map.with_index{ |e,ix| e[:name] || "series #{ix}" }
      rects = rect.hsplit( *([1]*names.size) )
      name_areas, bar_areas = rects.map{ |rc| rc.hsplit(1,1) }.transpose
      draw_samesize_texts( pdf, name_areas, names, align: :right )
      cols = colors(names.size)
      bar_areas.zip(cols).each do |rc0, col|
        _, rc1, = rc0.vsplit(1,1,1)
        rc, = rc1.hsplit(2,1)
        fill_rect( pdf, rc, col )
      end
    end

    def tick_unit(v)
      base = (10**Math.log10(v).round).to_f
      man = v/base
      return 0.5*base if man<0.6
      return base if man<1.2
      base*2
    end

    def tick_values(range)
      unit = tick_unit((range.max - range.min) * 0.1)
      i_low = (range.min / unit).ceil
      i_hi = (range.max / unit).floor
      (i_low..i_hi).map{ |i| i*unit }
    end

    def render_yticks(pdf, area, yrange, yvalues)
      h = (area.h / yvalues.size) * 0.7
      rects = yvalues.map{ |v|
        abs_y = abs_y_positoin( v, area, yrange )
        Rect.new( area.x, abs_y + h/2, area.w*0.9, h )
      }
      svalues = yvalues.map{ |v| "%g " % v }
      draw_samesize_texts( pdf, rects, svalues, align: :right )
    end
    
    def render_y_grid(pdf, area, yrange, yvalues)
      pdf.save_graphics_state do
        pdf.line_width = 0.5
        yvalues.each do |v|
          if v==0
            pdf.stroke_color "000000"
            pdf.undash
          else
            pdf.stroke_color "888888"
            pdf.dash([2,2])
          end
          abs_y = abs_y_positoin( v, area, yrange )
          pdf.stroke_horizontal_line area.x, area.right, at: abs_y
        end
      end
    end

  end
end
