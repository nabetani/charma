# frozen_string_literal: true

module Charma
  # 棒グラフの情報
  class BarChart < Chart
    # オプション
    OPTIONS = {
      title:nil,
      series:required(Array, Hash),
      x_ticks:nil_or(Array),
      x_title:nil,
      y_title:nil
    }.freeze

    # 系列につけられるオプション
    SERIES_OPTIONS = {
      y:required(Array, Numeric),
      name:nil
    }.freeze

    # BarChart の情報を作る。初期化する
    # :title :: グラフのタイトル
    # :series :: 系列
    # :x_ticks :: x軸につけるラベル
    # :x_title :: x軸のタイトル(グラフ下端)
    # :y_title :: y軸のタイトル(グラフ左端)
    #
    # 系列は Hash の Array になっている。
    # Hash のキーと値は以下の通り：
    # :y :: yの値。数値の配列。
    # :name :: 系列の名前(凡例に使う)
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

    # 系列の値を確認する。受け入れられない場合は例外。
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

    # チャートの種別を返す
    def chart_type
      :bar_chart
    end
  end
end
