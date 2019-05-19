# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::Renderer do
  describe "#chart_renderer" do
    it "returns renderer type" do
      r = Charma::Renderer.new(nil,nil)
      expect( r.chart_renderer( :bar_chart ) ).to eq( Charma::BarChartRenderer )
      expect( r.chart_renderer( :scatter_chart ) ).to eq( Charma::ScatterChartRenderer )
    end
  end
  describe "#split_page" do
    it "returns input rect if count==0" do
      r = Charma::Renderer.new(nil,nil)
      rect = Charma::Rect.new( 1, 10, 100, 1000 )
      split = r.split_page( rect, 1 )
      expect( split.size ).to eq(1)
      expect( split[0] ).to eq(rect)
    end
    it "split a horizontal rectangle horizontally" do
      r = Charma::Renderer.new(nil,nil)
      rect = Charma::Rect.new( 100, 1000, 12, 1 )
      (2..4).each do |s|
        split = r.split_page( rect, s )
        expect( split.size ).to eq(s)
        s.times do |ix|
          expect( split[ix] ).to eq(Charma::Rect.new(100+ix*12/s, 1000, 12/s, 1) )
        end
      end
    end
    it "split a vertical rectangle vertically" do
      r = Charma::Renderer.new(nil,nil)
      rect = Charma::Rect.new( 100, 1000, 1, 12 )
      (2..4).each do |s|
        split = r.split_page( rect, s )
        expect( split.size ).to eq(s)
        s.times do |ix|
          expect( split[ix] ).to eq(Charma::Rect.new(100, 1000+ix*12/s, 1, 12/s) )
        end
      end
    end
    it "divides a square into squares" do
      r = Charma::Renderer.new(nil,nil)
      rect = Charma::Rect.new( 100, 1000, 60, 60 )
      (2..5).each do |s|
        split = r.split_page( rect, s**2 )
        expect( split.size ).to eq(s**2)
        s.times do |y|
          s.times do |x|
            expected = Charma::Rect.new(100+x*60/s, 1000+y*60/s, 60/s, 60/s)
            expect( split[y*s+x] ).to eq(expected)
          end
        end
      end
    end
  end
end
