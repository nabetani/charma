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

  describe "#calc_yrange" do
    EXAMPLES = [
      { bins:10, y:[1,10], expected:[0.5,10.5] },
      { bins:100, y:[0.1,10], expected:[0.05,10.05] },
      { bins:6, y:[-4,1], expected:[-4.5, 1.5] },
      { bins:51, y:[-4,1], expected:[-4.05, 1.05] },
      { bins:4, y:[-4,-1], expected:[-4.5, -0.5] },
    ]
    describe "linear scale" do
      EXAMPLES.each do |bins:, y:, expected:|
        it "returns #{expected.inspect} if y-values are in #{y.inspect} and bins is #{bins}" do
          chart = Charma::ViolinChart.new(bins:bins, series:series_yrange(y))
          r = Charma::ViolinChartRenderer.new( chart, nil, rect01 )
          yrange = r.calc_yrange
          expect( yrange ).to almost_eq_ary( expected, 1e-7 )
        end
      end
    end
    describe "log10 scale" do
      EXAMPLES.each do |bins:, y:, expected:|
        real_y = y.map{ |e| 10.0**e }
        real_ex = expected.map{ |e| 10.0**e }
        it "returns #{real_ex.inspect} if y-values are in #{real_y.inspect} and bins is #{bins}" do
          chart = Charma::ViolinChart.new(y_scale: :log10, bins:bins, series:series_yrange(real_y))
          r = Charma::ViolinChartRenderer.new( chart, nil, rect01 )
          yrange = r.calc_yrange
          expect( yrange ).to almost_eq_ary( real_ex, 1e-7 )
        end
      end
    end
  end
end
