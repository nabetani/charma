# frozen_string_literal: true

module Charma
  # 棒グラフの情報
  class ScatterChart < Chart
    # オプション
    OPTIONS = {
      title:nil,
      series:required(Array, Hash),
      x_title:nil,
      y_title:nil,
      y2_title:nil,
      x_scale:one_of( nil, :linear, :log10 ),
      y_scale:one_of( nil, :linear, :log10 ),
      y2_scale:one_of( nil, :linear, :log10 ),
    }.freeze

    # 系列につけられるオプション
    SERIES_OPTIONS = {
      xy:nil_or(Array),
      xy2:nil_or(Array),
      style:one_of( nil, :line, :dot, :dot_and_line, :line_and_dot ),
      name:nil
    }.freeze

    # ScatterChart の情報を作る。初期化する
    # @option opts [Object] :title グラフのタイトル。

    # @option opts [Array] :series 系列。Hash の Array。必須。
    # @option opts [Object] :x_title x軸のタイトル(グラフ下端)。文字列。
    # @option opts [Object] :y_title y軸のタイトル(グラフ左端)。文字列。
    # @option opts [Object] :y2_title 第二y軸のタイトル(グラフ右端)。文字列。
    # @option opts [Symbol] :legend 凡例の位置。:none と :bottom のいずれか。省略時は :bottom。未対応。
    # @option opts [Symbol] :x_scale x軸のスケール。:linear または :log10
    # @option opts [Symbol] :y_scale x軸のスケール。:linear または :log10
    # @option opts [Symbol] :y2_scale x軸のスケール。:linear または :log10
    
    # 系列は Hash の Array になっている。
    # Hash のキーと値は以下の通り：
    # :xy [Array] 数値の配列の配列。数値は順に x, y。"xy: [[3, 1], [4, 1], [5, 9]]" のような感じ。第一y軸を使う。
    # :xy2 [Array] :xy と同様だが、第二y軸を使う。
    # :style [Symbol] 描画方法。以下のいずれか。nil, :line, :dot, :dot_and_line, :line_and_dot
    # :name [String] 系列の名前(凡例に使う)
    def initialize(opts)
      opts.each do |k,v|
        raise Errors::InvalidOption, "#{k.inspect} is not valid key" unless OPTIONS.has_key?(k)
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

    # 系列の値を確認する。受け入れられない場合は例外。
    def validate_series(ss)
      raise Errors::InvalidOption, "Series should not be empty" if ss.empty?
      ss.each do |s|
        s.each do |k,v|
          raise Errors::InvalidOption, "#{k.inspect} in series is not valid key" unless SERIES_OPTIONS.has_key?(k)
          validator = SERIES_OPTIONS[k]
          validator[k,v] if validator
        end
        raise Errors::InvalidOption, "Either xy or xy2 is required" unless s[:xy] || s[:xy2]
        raise Errors::InvalidOption, "You can not specify both xy and xy2" if s[:xy] && s[:xy2]
        raise Errors::InvalidOption, "xy should be Array of pair of Numeric" unless acceptable_xy(s[:xy])
        raise Errors::InvalidOption, "xy2 should be Array of pair of Numeric" unless acceptable_xy(s[:xy2])
      end
      no_xy = ss.none?{ |s| !!s[:xy] }
      raise Errors::InvalidOption, "At least one series has xy" if no_xy
    end

    # xy または xy2 の値が受け入れられるかどうかを調べる
    # @param [Object] val series[:xy] または series[:xy2] の値。調査対象。
    # @return [true, false] 受け入れ可能なら true。
    def acceptable_xy(val)
      return true if val.nil?
      return false unless val.respond_to?( :all? )
      val.all? do |e|
        e.respond_to?(:size) \
        && e.size==2 \
        && e.respond_to?(:[])  \
        && e[0].is_a?(Numeric) \
        && e[1].is_a?(Numeric) \
      end
    end

    # 第二y軸があるかどうか。ある場合は true。
    def y2?
      !! @opts[:series].any?{ |e| e[:xy2] }
    end

    # チャートの種別を返す
    def chart_type
      :scatter_chart
    end
  end
end
