# frozen_string_literal: true

module Charma
  # バイオリンチャートの情報
  class ViolinChart < Chart
    # オプション
    OPTIONS = {
      title:nil,
      series:required(Array, Hash),
      x_ticks:nil_or(Array),
      x_title:nil,
      y_title:nil,
      y_scale:one_of( nil, :linear, :log10 ),
      # with_calc:one_of( nil, :series, :x, :all ) # TODO: 幅の計算方法を選べるようにする
      bins:nil_or(PositiveInteger)
    }.freeze

    # 系列につけられるオプション
    SERIES_OPTIONS = {
      y:nil_or(Array, Array, Numeric),
      name:nil
    }.freeze
    
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

    def validate_series_y(sym, y)
      return if y.nil?
      msg = "Series.#{sym} should be Array of Array of Numeric"
      raise Errors::InvalidOption, msg unless y.is_a?( Array )
      okay = y.all? do |vals|
        vals.is_a?( Array ) && vals.all? do |val|
          val.is_a?( Numeric )
        end
      end
      raise Errors::InvalidOption, msg unless okay
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
      end
    end

    # 第二y軸があるかどうか。ある場合は true。
    def y2?
      false
    end

    # ビンの数を返す
    def bins
      self[:bins] || 100
    end

    # チャートの種別を返す
    def chart_type
      :violin_chart
    end
  end
end
