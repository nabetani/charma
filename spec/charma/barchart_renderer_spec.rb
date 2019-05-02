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

  describe "#calc_yrange" do
    it "create zero and positive range if all values are positive" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }])
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      range = r.calc_yrange
      expect( range.size ).to eq(2)
      expect( range[0] ).to eq(0)
      expect( range[1] ).to eq(11)
    end
    it "create negative and positive range if there are positive and negative values" do
      chart = Charma::BarChart.new(series:[{ y:[3, -10, 20] }])
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      range = r.calc_yrange
      expect( range.size ).to eq(2)
      expect( range[0] ).to eq(-11)
      expect( range[1] ).to eq(22)
    end
    it "create negative and zero range if all values are negative" do
      chart = Charma::BarChart.new(series:[{ y:[-3, -30, -20] }])
      r = Charma::BarChartRenderer.new( chart, nil, Charma::Rect.new( 0, 0, 1, 1) )
      range = r.calc_yrange
      expect( range.size ).to eq(2)
      expect( range[0] ).to eq(-33)
      expect( range[1] ).to eq(0)
    end
  end

  describe "#draw_bars" do
    it "renders bars" do
      chart = Charma::BarChart.new(series:[{ y:[3, 10, 5] }])
      fake_canvas = FakeCanvas.new
      r = Charma::BarChartRenderer.new( chart, fake_canvas, Charma::Rect.new( 0, 0, 100, 1000) )
      ys = [10,20]
      cols = %w(001 002)
      r.draw_bars( ys, Charma::Rect.new( 0, 0, 80, 1000 ), cols, [0,100] )
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

