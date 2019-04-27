# frozen_string_literal: true

module Charma
  # チャートの基底クラス
  class Chart
    def self.required(type)
      lambda do |k, v|
        raise Charma::Error, "#{k} is required" unless v
        raise Charma::Error, "#{k} should be #{type}" unless v.is_a?(type)
      end
    end

    def initialize(opts)
      @opts = opts
    end

    def has_y2?
      false
    end

    def [](key)
      @opts[key]
    end
  end
end
