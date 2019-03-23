require "charma/version"
require "prawn"

module Charma
  class Error < StandardError; end

  Rect = Struct.new( :x, :y, :w, :h ) do
    def vsplit( *rel_hs )
      rel_sum = rel_hs.sum
      abs_y = y.to_f
      rel_hs.map{ |rel_h|
        abs_h = rel_h.to_f * h / rel_sum
        rc = Rect.new( x, abs_y, w, abs_h )
        abs_y -= abs_h
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

    def bottom
      y-h
    end

    def topleft
      [x,y]
    end
  end

  class Chart
    def stroke_rect( pdf, rect )
      pdf.stroke{
        pdf.rectangle( [rect.x, rect.y], rect.w, rect.h )
      }
    end

    def draw_text( pdf, rect, text, opts={} )
      pdf.text_box( text,
        at:rect.topleft,
        width:rect.w,
        height:rect.h,
        align: (opts[:align] || :center),
        valign: (opts[:valign] || :center),
        size: rect.h,
        overflow: :shrink_to_fit )
    end
  end

  class BarChart < Chart
    def initialize(opts)
      @opts = opts
    end

    def draw_bar(pdf, rect, y)
      bar = Rect.new(
        rect.x + rect.w*0.25,
        y.max,
        rect.w*0.5,
        y.max - y.min )
      stroke_rect( pdf, bar )
    end

    def render_chart(pdf, rect, yrange)
      stroke_rect(pdf, rect)
      y_values = @opts[:y_values].map(&:to_f)
      bar_areas = rect.hsplit(*Array.new(y_values.size){1})
      f = ->(v,rc){
        (v-yrange[0]) * rc.h / (yrange[1]-yrange[0]) + rc.bottom
      }
      y_values.zip(bar_areas).each do |v, rc|
        draw_bar(pdf, rc, [f[v,rc], f[0,rc]])
      end
    end

    def render( pdf, rect )
      stroke_rect(pdf, rect)
      title, main, tick, bottom = rect.vsplit( 1, 7, 0.5, 1 )
      draw_text( pdf, title, "title" )
      hratio = [1,10]
      ytick, chart = main.hsplit(*hratio)
      ymin = [0, @opts[:y_values].min * 1.1].min
      ymax = [0, @opts[:y_values].max * 1.1].max
      render_chart(pdf, chart, [ymin, ymax])
    end
  end

  class Page
    def initialize( doc )
      @doc = doc
      @graphs = []
    end

    def create_opts
      {
        page_size: "A4",
        page_layout: :landscape,
      }
    end

    def area(mb, _)
      Rect.new(mb.left, mb.top, mb.width, mb.height)
    end

    def render(pdf)
      pdf.stroke_axis
      @graphs.each.with_index do |g,ix|
        g.render( pdf, area(pdf.margin_box, ix) )
      end
    end

    def add_barchart(opts)
      @graphs.push BarChart.new(opts)
    end
  end

  class Document
    def initialize( &block )
      @pages = []
      block[self]
    end

    def new_page(&block)
      p @pages
      page = Page.new(self)
      block[page]
      @pages.push page
    end

    def render( filename )
      raise "no page added" if @pages.empty?
      opts = @pages.first.create_opts
      Prawn::Document.generate(filename, opts) do |pdf|
        @pages.each.with_index do |page,ix|
          pdf.start_new_page(page.create_opts) if ix != 0
          page.render(pdf)
        end
      end
    end
  end
end
