# frozen_string_literal: true

module Charma
  # Charma Page
  class Page
    def initialize(
      font:nil,
      page_size:DEFAULT_PAGE_SIZE,
      page_layout: nil,
      &block
    )
      @charts = []
      @font = font
      @size = parse_papersize( page_size, page_layout )
      block[self] if block
    end

    attr_reader :size
    attr_reader :charts

    def adjust_layout(size, page_layout)
      s,l = size.rectangular.minmax
      case page_layout
      when :landscape
        l+s*1i
      when :portrait
        s+l*1i
      when nil
        size
      else
        raise "#{@page_layout.inspect} is not supported page_layout"
      end
    end

    def parse_papersize( page_size, page_layout )
      case page_size
      when /^[AB]\d+$/
        s = PAPER_SIZES[page_size.to_sym]
        raise "#{page_size.inspect} is not supported paper size" unless s
        adjust_layout(s, page_layout)
      when /^([0-9]+(?:\.[0-9]*)?)[^0-9\.]+([0-9]+(?:\.[0-9]*)?)/
        w, h = [$1,$2].map(&:to_f).minmax
        adjust_layout(w + h * 1.0i, page_layout)
      when Array
        w, h = page_size.minmax
        adjust_layout(w + h * 1.0i, page_layout)
      else
        raise Charma::Error, "unexpected size : #{page_size}"
      end
    end

    def w
      size.real
    end

    def h
      size.imag
    end

    def add_chart( chart )
      @charts.push chart
    end
  end
end
