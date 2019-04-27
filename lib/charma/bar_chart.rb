# frozen_string_literal: true

module Charma
  # 棒グラフの情報
  class BarChart < Chart
    VALID_OPTIONS = {
      title:nil,
      series:required(Array),
      x_ticks:nil,
      x_title:nil,
      y_title:nil
    }.freeze

    def initialize(opts)
      opts.each do |k,v|
        raise Charma::Error, "#{k.inspect} is not valid key" unless VALID_OPTIONS.has_key?(k)
        validator = VALID_OPTIONS[k]
        validator[k,v] if validator
      end
      VALID_OPTIONS.each do |k,v|
        next unless v
        v[k, opts[k]]
      end
      super(opts)
    end

    def chart_type
      :bar_chart
    end
  end
end
