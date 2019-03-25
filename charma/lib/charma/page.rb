# frozen_string_literal: true

module Charma
  class Page
    def initialize( opts )
      @opts = opts
      @graphs = []
    end

    def create_opts
      {
        page_size: "A4",
        page_layout: :landscape,
      }.merge(@opts)
    end

    def split_rect( rc, pos, size )
      horz = ([10,1]*size[0])[0..-2]
      vrect = rc.hsplit( *horz ).select.with_index{ |_,ix| ix.even? }[pos[0]]
      vert = ([10,1]*size[1])[0..-2]
      vrect.vsplit( *vert ).select.with_index{ |_,ix| ix.even? }[pos[1]]
    end

    def area(mb, ix)
      t = Rect.new(mb.left, mb.top, mb.width, mb.height)
      c = @graphs.size
      case c
      when 1
        t
      when 2..3
        split_rect( t, [ix,0], [c,1] )
      else
        w = Math.sqrt(c).ceil
        h = (c.to_f/w).ceil
        split_rect( t, ix.divmod(w).reverse, [w, h] )
      end
    end

    def render(pdf)
      pdf.font File.expand_path(@opts[:font]) if @opts[:font]
      @graphs.each.with_index do |g,ix|
        g.render( pdf, area(pdf.margin_box, ix) )
      end
    end

    def add_barchart(opts)
      @graphs.push BarChart.new(opts)
    end

    def add_linechart(opts)
      @graphs.push LineChart.new(opts)
    end

    def add_violinchart(opts)
      @graphs.push ViolinChart.new(opts)
    end
  end
end
