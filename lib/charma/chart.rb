# frozen_string_literal: true

module Charma
  # チャートの基底クラス
  class Chart

    # 必要とされるオプションであることを示すマーカー
    # type :: 値の型
    # inner_type :: 値の要素型。値が Array の場合などに使う。
    def self.required(type, inner_type = nil)
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

    # なくてもいいオプションであることを示すマーカー
    # type :: 値の型
    # inner_type :: 値の要素型。値が Array の場合などに使う。
    def self.nil_or(type, inner_type = nil)
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

    # Chart を構築する
    # opts :: オプションを示す Hash。
    def initialize(opts)
      @opts = opts
    end

    # 第二y軸があるかどうか。ある場合は true。
    def y2?
      false
    end

    # オプションへのアクセサ
    def [](key)
      @opts[key]
    end

  end
end
