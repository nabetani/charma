# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::ViolinChartRenderer do
  def series_yrange( y, y2=nil )
    seri = lambda do |name,vals|
      mid = vals.sum / vals.size.to_f
      { name=>[[ mid, *vals, mid ]] }
    end
    r=[]
    r.push seri[:y, y]
    r.push seri[:y2, y2] if y2
    r
  end

  def rect01
    Charma::Rect.new( 0, 0, 1, 1)
  end

  describe ".new" do
    it "creates ViolinChartRenderer" do
      chart = Charma::ViolinChart.new(series:[{y:[[1]]}])
      expect{
        Charma::ViolinChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      }.not_to raise_error
    end
  end

  describe "#calc_yranges" do
    describe "without y2" do
      EXAMPLES = [
        [[0,1.099], [0,1]], # 全て0以上なら範囲も0以上になる
        [[-1.099, 0], [0,-1]], # 全て0以下なら範囲も0以下になる
        [[-5.99, 5.99], [-5,5]], # 範囲が正負に渡っているなら普通に拡張される
        [[0,1.0991], [0.0001,1.0001]], # 全て0以上なら範囲も0以上になる
        [[-1.0991, 0], [-0.0001,-1.0001]], # 全て0以下なら範囲も0以下になる
        [[100-0.099, 101+0.099], [100, 101]], # 範囲が余裕を持って正なら、普通に拡張される
        [[-101-0.099, -100+0.099], [-100, -101]], # 範囲が余裕を持って負なら、普通に拡張される
      ]

      LOG_EXAMPLES = [
        [[-0.099,1.099], [0,1]], # 正負に関係なく普通に拡張される
        [[10-0.099,10+1.099], [10,11]], # 普通に拡張される
        [[-0.099*10,1.099*10], [0,10]], # 正負に関係なく普通に拡張される
      ]

      EXAMPLES.each do |expected, input|
        it "returns #{expected.inspect} if y-values are in #{input.inspect}" do
          chart = Charma::ViolinChart.new(series:series_yrange(input))
          r = Charma::ViolinChartRenderer.new( chart, nil, rect01 )
          yrange, y2range = r.calc_yranges
          expect( yrange ).to almost_eq_ary( expected, 1e-7 )
          expect( y2range ).to be_nil
        end
      end
      describe "without y2, log scale" do
        LOG_EXAMPLES.each do |ex, y|
          real_ex = ex.map{ |e| 10**e }
          real_y = y.map{ |e| 10**e }
          it "returns #{real_ex.inspect} in log10 scale if y-values are in #{real_y.inspect}" do
            chart = Charma::ViolinChart.new(y_scale: :log10, series:series_yrange(real_y))
            r = Charma::ViolinChartRenderer.new( chart, nil, rect01 )
            yrange, y2range = r.calc_yranges
            expect( yrange ).to almost_eq_ary( real_ex, 1e-7 )
            expect( y2range ).to be_nil
          end
        end
      end
    end
  end
end
