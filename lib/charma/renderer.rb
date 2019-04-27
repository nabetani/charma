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
      canvas.new_page(page)
      page_rect = canvas.page_rect
      p page_rect
      page.charts.each do |chart|
        t = chart_renderer(chart.chart_type)
        t.new( chart, canvas, page_rect ).render
      end
    end
  end
end
