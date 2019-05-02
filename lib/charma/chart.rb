# frozen_string_literal: true

module Charma
  # チャートの基底クラス
  class Chart
    def self.required(type, inner_type=nil)
      lambda do |k, v|
        raise Errors::InvalidOption, "#{k} is required" if v.nil?
        raise Errors::InvalidOption, "#{k} should be #{type}" unless v.is_a?(type)
        if inner_type
          unless v.all?{ |e| e.is_a?(inner_type) }
            raise Errors::InvalidOption, "item in #{k} should be #{inner_type}"
          end
        end
      end
    end

    def self.nil_or(type, inner_type=nil)
      lambda do |k, v|
        return if v.nil?
        raise Errors::InvalidOption, "#{k} should be #{type}" unless v.is_a?(type)
        if inner_type
          unless v.all?{ |e| e.is_a?(inner_type) }
            raise Errors::InvalidOption, "item in #{k} should be #{inner_type}"
          end
        end
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
