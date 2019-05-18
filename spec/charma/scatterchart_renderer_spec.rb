# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::ScatterChartRenderer do
  def series( scount, xycount )
    Array.new(scount) do |s|
      xy = Array.new( xycount ) do |i|
        x = (i+Math.sin(i))*0.1
        y = Math.sin(i)+Math.cos(i*i)*0.1
        [x,y]
      end
      { name: scount, xy: xy }
    end
  end

  def series_yrange( names, minmax )
    names.map.with_index do |name, ix|
      mid = minmax.sum / minmax.size.to_f
      { name=>[ mid, minmax, mid ].flatten.map{ |y| [ix,y] }}
    end
  end

  def rect01
    Charma::Rect.new( 0, 0, 1, 1)
  end

  describe ".new" do
    it "creates ScatterChartRenderer" do
      chart = Charma::ScatterChart.new(series:series(3,4))
      expect{
        Charma::ScatterChartRenderer.new( chart, nil, rect01 )
      }.not_to raise_error
    end
  end

  describe "#calc_yranges" do
    [
      [[0,1.099], [0,1]], # 全て0以上なら範囲も0以上になる
      [[-1.099, 0], [0,-1]], # 全て0以下なら範囲も0以下になる
      [[-5.99, 5.99], [-5,5]], # 範囲が正負に渡っているなら普通に拡張される
      [[0,1.0991], [0.0001,1.0001]], # 全て0以上なら範囲も0以上になる
      [[-1.0991, 0], [-0.0001,-1.0001]], # 全て0以下なら範囲も0以下になる
      [[100-0.099, 101+0.099], [100, 101]], # 範囲が余裕を持って正なら、普通に拡張される
      [[-101-0.099, -100+0.099], [-100, -101]], # 範囲が余裕を持って負なら、普通に拡張される
    ].each do |expected, input|
      it "returns #{expected.inspect} if y-values are in #{input.inspect}" do
        chart = Charma::ScatterChart.new(series:series_yrange(%i(xy), input))
        r = Charma::ScatterChartRenderer.new( chart, nil, rect01 )
        yrange, y2range = r.calc_yranges
        expect( yrange ).to almost_eq_ary( expected, 1e-7 )
        expect( y2range ).to be_nil
      end
    end
  end
end

