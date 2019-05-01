# frozen_string_literal: true

module Charma
  # 棒グラフの情報
  class BarChart < Chart
    OPTIONS = {
      title:nil,
      series:required(Array, Hash),
      x_ticks:nil_or(Array),
      x_title:nil,
      y_title:nil
    }.freeze

    SERIES_OPTIONS = {
      y:required(Array, Numeric),
      name:nil
    }.freeze

    def initialize(opts)
      opts.each do |k,v|
        raise Charma::Error, "#{k.inspect} is not valid key" unless OPTIONS.has_key?(k)
        validator = OPTIONS[k]
        validator[k,v] if validator
      end
      OPTIONS.each do |k,v|
        next unless v
        v[k, opts[k]]
      end
      validate_series(opts[:series])
      super(opts)
    end

    def validate_series(ss)
      raise Errors::InvalidOption, "series should not be empty" if ss.empty?
      ss.each do |s|
        s.each do |k,v|
          raise Errors::InvalidOption, "#{k.inspect} in series is not valid key" unless SERIES_OPTIONS.has_key?(k)
          validator = SERIES_OPTIONS[k]
          validator[k,v] if validator
        end
      end
    end

    def chart_type
      :bar_chart
    end
  end
end
