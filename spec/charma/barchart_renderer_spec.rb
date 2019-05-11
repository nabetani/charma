# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::BarChartRenderer do
  def series( scount, ycount )
    Array.new(scount) do |s|
      y = Array.new( ycount ) do |i|
        Math.sin( (s+2)**(i+2) )
      end
      { 
        name: scount,
        y: y
      }
    end
  end

  describe ".new" do
    it "creates BarChartRenderer" do
      chart = Charma::BarChart.new(series:series(3,4))
      expect{
        Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      }.not_to raise_error
    end
  end

  describe "#calc_yranges" do
    it "creates zero and positive range if all values are positive" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }])
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      yrange, y2range = r.calc_yranges
      expect( yrange ).to almost_eq_ary( [0, 10].map{ |e| e*1.099 }, 1e-7 )
      expect( y2range ).to be_nil
    end

    it "creates 0 to 1 range if all the values are zero" do
      chart = Charma::BarChart.new(series:[{ y:[0,0,0] }])
      r = Charma::BarChartRenderer.new(chart, nil, Charma::Rect.new( 0, 0, 1, 1))
      yrange, y2range = r.calc_yranges
      expect( yrange ).to eq([0,1.099])
      expect( y2range ).to be_nil
    end

    it "creates 0 to 1 range if all the values are zero(with y2)" do
      chart = Charma::BarChart.new(series:[{ y:[0,0,0] }, { y2:[0,0,0] }])
      r = Charma::BarChartRenderer.new(chart, nil, Charma::Rect.new( 0, 0, 1, 1))
      yrange, y2range = r.calc_yranges
      expect( yrange ).to eq([0,1].map{ |e| e*1.099})
      expect( y2range ).to eq([0,1].map{ |e| e*1.099})
    end

    it "creates -1 to 0 range if another values are negative(y)" do
      chart = Charma::BarChart.new(series:[{ y:[0,0,0] }, { y2:[-10,-100,-1000] }])
      r = Charma::BarChartRenderer.new(chart, nil, Charma::Rect.new( 0, 0, 1, 1))
      yrange, y2range = r.calc_yranges
      expect( yrange ).to almost_eq_ary([-1,0].map{ |e| e*1.099}, 1e-7)
      expect( y2range ).to almost_eq_ary([-1099,0], 1e-7)
    end

    it "creates -0.25 to 0.75 range if another values are negative and positive" do
      chart = Charma::BarChart.new(series:[{ y:[0,0] }, { y2:[-25, 75] }])
      r = Charma::BarChartRenderer.new(chart, nil, Charma::Rect.new( 0, 0, 1, 1))
      yrange, y2range = r.calc_yranges
      expect( yrange ).to almost_eq_ary([-0.25, 1].map{ |e| e*1.099}, 1e-7)
      expect( y2range ).to almost_eq_ary([-25, 100].map{ |e| e*1.099}, 1e-7 )
    end

    it "creates 0 to -1 range if another values are negative(y2)" do
      chart = Charma::BarChart.new(series:[{ y:[-1,-10,-100] }, { y2:[0,0,0] }])
      r = Charma::BarChartRenderer.new(chart, nil, Charma::Rect.new( 0, 0, 1, 1))
      yrange, y2range = r.calc_yranges
      expect( yrange ).to almost_eq_ary([-109.9,0], 1e-7)
      expect( y2range ).to almost_eq_ary([-1.099,0], 1e-7)
    end

    it "creates -1.099 to 1.099 and -10.99 to 10.99 ranges" do
      y = { y:[-1, 0, -0.5] }
      y2 = { y2:[1, 10, 7] }
      chart = Charma::BarChart.new(series:[y, y2])
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      yrange, y2range = r.calc_yranges
      expect( yrange ).to eq([-1.099, 1.099])
      expect( y2range ).to eq([-10.99, 10.99])
    end

    it "creates negative and zero range if all the values are negative" do
      chart = Charma::BarChart.new(series:[{ y:[-3, -30, -20] }])
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      yrange, y2range = r.calc_yranges
      expect( yrange ).to almost_eq_ary([-30*1.099,0], 1e-5)
      expect( y2range ).to be_nil
    end

    describe "complex case" do
      it "creates 1.099*-1 to 1.099*1.6 and 1.099*-12.5 to 1.099*20 ranges" do
        y = { y:[-1, 0, 1] }
        y2 = { y2:[-5, 0, 20] }
        chart = Charma::BarChart.new(series:[y, y2])
        r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
        yrange, y2range = r.calc_yranges
        expect( yrange ).to almost_eq_ary([1.099*-1, 1.099*1.6], 1e-5)
        expect( y2range ).to almost_eq_ary([1.099*-12.5, 1.099*20], 1e-5)
      end
      it "creates 1.099*-2 to 1.099*9 and 1.099*-5 to 1.099*22.5 ranges" do
        y = { y:[-1, 9] }
        y2 = { y2:[-5, 20] }
        chart = Charma::BarChart.new(series:[y, y2])
        r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
        yrange, y2range = r.calc_yranges
        expect( yrange ).to almost_eq_ary([1.099*-2, 1.099*9], 1e-5)
        expect( y2range ).to almost_eq_ary([1.099*-5, 1.099*22.5], 1e-5)
      end
    end
  end

  describe "#draw_bars" do
    it "renders bars" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }, { y:[9, 8, 7] }])
      fake_canvas = FakeCanvas.new
      area = Charma::Rect.new( 0, 0, 100, 1000)
      r = Charma::BarChartRenderer.new( chart, fake_canvas, area )
      ys = [10,20]
      cols = %w(001 002)
      r.draw_bars( ys, Charma::Rect.new( 0, 0, 80, 1000 ), cols, [0,100], [0,100] )
      expect( fake_canvas.called.size ).to eq(2)
      first = fake_canvas.called[0]
      second = fake_canvas.called[1]
      expect( first[:method] ).to eq( :fill_rect )
      expect( first[:args][0].x ).to eq( 10 )
      expect( first[:args][0].w ).to eq( 30 )
      expect( first[:args][0].y ).to eq( 900 )
      expect( first[:args][0].h ).to eq( 100 )
      expect( first[:args][1] ).to eq( "001" )
      expect( second[:method] ).to eq( :fill_rect )
      expect( second[:args][0].x ).to eq( 40 )
      expect( second[:args][0].w ).to eq( 30 )
      expect( second[:args][0].y ).to eq( 800 )
      expect( second[:args][0].h ).to eq( 200 )
      expect( second[:args][1] ).to eq( "002" )
    end
  end

  describe "#draw_bars with y2" do
    it "renders bars" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }, { y2:[9, 8, 7] }])
      fake_canvas = FakeCanvas.new
      area = Charma::Rect.new( 0, 0, 100, 1000)
      r = Charma::BarChartRenderer.new( chart, fake_canvas, area )
      ys = [10,200]
      cols = %w(001 002)
      r.draw_bars( ys, Charma::Rect.new( 0, 0, 80, 1000 ), cols, [0,100], [0,1000] )
      expect( fake_canvas.called.size ).to eq(2)
      first = fake_canvas.called[0]
      second = fake_canvas.called[1]
      expect( first[:method] ).to eq( :fill_rect )
      expect( first[:args][0].x ).to eq( 10 )
      expect( first[:args][0].w ).to eq( 30 )
      expect( first[:args][0].y ).to eq( 900 )
      expect( first[:args][0].h ).to eq( 100 )
      expect( first[:args][1] ).to eq( "001" )
      expect( second[:method] ).to eq( :fill_rect )
      expect( second[:args][0].x ).to eq( 40 )
      expect( second[:args][0].w ).to eq( 30 )
      expect( second[:args][0].y ).to eq( 800 )
      expect( second[:args][0].h ).to eq( 200 )
      expect( second[:args][1] ).to eq( "002" )
    end
  end

  describe "#create_colors" do
    it "creates colors for single series" do
      chart = Charma::BarChart.new(series:series(1,4))
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      cols = r.create_colors
      expect( cols.size ).to eq(4)
      expect( cols.map(&:size) ).to eq( [1]*4 )
      expect( cols.flatten.uniq.size ).to eq(4) # y の数だけ色がある
    end

    it "creates colors for multi series" do
      chart = Charma::BarChart.new(series:series(3,4))
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      cols = r.create_colors
      expect( cols.size ).to eq(4)
      expect( cols.map(&:size) ).to eq( [3]*4 )
      3.times do |s|
        c = cols.map{ |e| e[s] }.uniq
        expect( c.size ).to eq(1)
      end
      expect( cols.flatten.uniq.size ).to eq(3) # 系列の数だけ色がある
    end
  end

  describe "#render_chart" do
    it "renders bars ( 1 series, 3 values )" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }])
      fake_canvas = FakeCanvas.new
      r = Charma::BarChartRenderer.new( chart, fake_canvas, Charma::Rect.new( 0, 0, 100, 100) )
      r.render_chart
      fill_rects = fake_canvas.called.select{ |m| m[:method]==:fill_rect }
      expect( fill_rects.size ).to eq(3)
    end

    it "renders bars ( 5 series, 3 values )" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }]*5)
      fake_canvas = FakeCanvas.new
      r = Charma::BarChartRenderer.new( chart, fake_canvas, Charma::Rect.new( 0, 0, 100, 100) )
      r.render_chart
      fill_rects = fake_canvas.called.select{ |m| m[:method]==:fill_rect }
      bars = 5 * 3
      expect( fill_rects.size ).to eq(bars)
    end
  end
end

