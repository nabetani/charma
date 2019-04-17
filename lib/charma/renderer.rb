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
    
    def render_page( canvas, page )
      page.charts.each do |chart|
        area = Rect.new( 0, 0, page.w, page.h )
        t = chart_renderer(chart.chart_type)
        t.new( chart, canvas, area ).render
      end
    end
  end
end
