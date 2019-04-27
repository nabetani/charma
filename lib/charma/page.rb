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
      @page_size = page_size
      @page_layout = page_layout
      @size = parse_papersize
      block[self] if block
    end

    def adjust_layout(size)
      s,l = size.rectangular.minmax
      case @page_layout
      when :landscape
        l+s*1i;
      when :portlait
        s+l*1i;
      when nil
        size
      else
        raise "#{@page_layout.inspect} is not supported page_layout"
      end
    end

    def parse_papersize
      case @page_size
      when /^[AB]\d+$/
        adjust_layout(PAPER_SIZES[@page_size.to_sym])
      when /^([0-9]+(?:\.[0-9]*)?)[^0-9\.]+([0-9]+(?:\.[0-9]*)?)/
        w, h = [$1,$2].map(&:to_f).minmax
        adjust_layout(w + h * 1.0i)
      else
        raise Charma::Error, "unexpected size : #{@page_size}"
      end
    end

    attr_reader :size
    attr_reader :charts

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
