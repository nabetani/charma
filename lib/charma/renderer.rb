# frozen_string_literal: true

module Charma
  class Renderer
    def initialize( pages, opts )
      @pages = pages
      @opts = opts
    end

    def chart_renderer(ct)
      case ct
      when :bar_chart
        BarChartRenderer
      else
        raise Charma::Error, "unexpected chart type: #{ct}"
      end
    end

    def split_page( total, count )
      xcount = (1..count ).min_by{ |w|
        h = ( count.to_r / w.to_r ).ceil
        cw = total.w.to_f / w
        ch = total.h.to_f / h
        Math.log(cw/ch).abs
      }
      ycount = ( count.to_r / xcount.to_r ).ceil
      total.vsplit( *Array.new(ycount, 1) ).map{ |rc|
        rc.hsplit( *Array.new(xcount, 1) )
      }.flatten
    end

    def render_page( canvas, page )
      rects = split_page( canvas.page_rect, page.charts.size )
      page.charts.zip(rects).each do |chart, rect|
        t = chart_renderer(chart.chart_type)
        t.new( chart, canvas, rect ).render
      end
    end
  end
end
