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
        "%02x" % (v*255).round
      }
      Array.new(n){ |i|
        t = i*3.0/n
        [f[t],f[t+1],f[t+2]].join
      }
    end

    def draw_samesize_texts( pdf, rects, texts, opts={} )
      inf = 1e100
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
  end

  class BarChart < Chart
    def initialize(opts)
      @opts = opts
      @opts[:colors] ||= colors(opts[:y_values].size)
    end

    def draw_bar(pdf, rect, y, col)
      ratio = 0.75
      bar = Rect.new(
        rect.x + rect.w*(1-ratio)/2,
        y.max,
        rect.w*ratio,
        y.max - y.min )
      fill_rect( pdf, bar, col )
    end

    def abs_y_positoin(v, rc, yrange)
      (v-yrange[0]) * rc.h / (yrange[1]-yrange[0]) + rc.bottom
    end

    def render_chart(pdf, rect, yrange)
      stroke_rect(pdf, rect)
      y_values = @opts[:y_values].map(&:to_f)
      bar_areas = rect.hsplit(*Array.new(y_values.size){1})
      f = lambda{|v, rc|
        abs_y_positoin( v, rc, yrange)
      }
      y_values.zip(bar_areas, @opts[:colors]).each do |v, rc, col|
        draw_bar(pdf, rc, [f[v,rc], f[0,rc]], col)
      end
    end

    def render_xticks(pdf, area)
      rects = area.hsplit(*Array.new(@opts[:x_ticks].size){ 1 }).map{ |rc0|
        rc0.hsplit(1,8,1)[1]
      }
      draw_samesize_texts( pdf, rects, @opts[:x_ticks], valign: :top )
    end

    def tick_unit(v)
      base = (10**Math.log10(v).round).to_f
      man = v/base
      return 0.5*base if man<0.7
      return base if man<1.5
      base*2
    end

    def render_yticks(pdf, area, yrange)
      f = lambda{|v, rc|
        abs_y_positoin( v, rc, yrange)
      }
      unit = tick_unit((yrange.max - yrange.min) * 0.1)
      i_low = (yrange.min / unit).ceil
      i_hi = (yrange.max / unit).floor
      values = (i_low..i_hi).map{ |i| i*unit }
      h = (area.h / values.size) * 0.7
      rects = values.map{ |v|
        abs_y = abs_y_positoin( v, area, yrange )
        Rect.new( area.x, abs_y + h/2, area.w*0.9, h )
      }
      svalues = values.map{ |v| "%g " % v }
      draw_samesize_texts( pdf, rects, svalues, align: :right )
    end

    def render( pdf, rect )
      stroke_rect(pdf, rect)
      title_text = @opts[:title]
      title, main, ticks, bottom = rect.vsplit(
        (title_text ? 1 : 0),
        7, 
        (@opts[:x_ticks] ? 0.5 : 0),
        1 )
      draw_text( pdf, title, title_text ) if title_text
      hratio = [1,10]
      yticks, chart = main.hsplit(*hratio)
      ymin = [0, @opts[:y_values].min * 1.1].min
      ymax = [0, @opts[:y_values].max * 1.1].max
      yrange = [ymin, ymax]
      render_chart(pdf, chart, yrange)
      if @opts[:x_ticks]
        _, xticks = ticks.hsplit(*hratio)
        render_xticks(pdf, xticks)
      end
      render_yticks(pdf, yticks, yrange)
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
