# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::ScatterChart do
  describe ".new" do
    it "creates ScatterChart with parameters" do
      c = Charma::ScatterChart.new(
        title:"TITLE",
        series:[{xy: [[3, 1], [4, 1], [5, 9], [2, 6], [5, 3], [5, 8], [9, 7]]}],
        x_title:"X TITLE",
        y_title:"Y TITLE"
      )
      expect(c[:title]).to eq( "TITLE" )
      expect(c[:series]).to eq(
        [{xy: [[3, 1], [4, 1], [5, 9], [2, 6], [5, 3], [5, 8], [9, 7]]}]
      )
      expect(c[:x_title]).to eq( "X TITLE")
      expect(c[:y_title]).to eq( "Y TITLE")
    end

    it "raises if no series" do
      expect{
        Charma::ScatterChart.new({})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises unless series is Array of Hash" do
      expect{
        Charma::ScatterChart.new(series:123)
      }.to raise_error( Charma::Errors::InvalidOption )
      expect{
        Charma::ScatterChart.new(series:[1])
      }.to raise_error( Charma::Errors::InvalidOption )
      expect{
        Charma::ScatterChart.new(series:[{xy:[[1,2]]},123])
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if series is empty" do
      expect{
        Charma::ScatterChart.new(series:[])
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if series.xy is NOT Array of pair of Numeric" do
      [
        %i(foo bar),
        [1,2,3],
        [[1],[2,3]],
        [[1,2],[2,3,4],[3,4]],
        [[1,2],[2,3,4],[3,4]],
      ].each do |xy|
        expect{
          Charma::ScatterChart.new(series:[xy:xy])
        }.to raise_error( Charma::Errors::InvalidOption )
      end
    end

    it "raises if series.xy2 is NOT Array of pair of Numeric" do
      [
        %i(foo bar),
        [1,2,3],
        [[1],[2,3]],
        [[1,2],[2,3,4],[3,4]],
        [[1,2],[2,3,4],[3,4]],
      ].each do |xy|
        expect{
          Charma::ScatterChart.new(series:[{xy:[[1,2]]},{xy2:xy}])
        }.to raise_error( Charma::Errors::InvalidOption )
      end
    end

    it "raises if a series has both xy and xy2" do
      xy = xy2 = [[1,2],[3,4],[5,6]]
      expect{
        Charma::ScatterChart.new(series:[{xy:xy,xy2:xy2}])
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if no series has xy" do
      xy2 = [[1,2],[3,4],[5,6]]
      expect{
        Charma::ScatterChart.new(series:[{xy2:xy2}])
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if there is unexpected key" do
      xy = [[1,2],[3,4],[5,6]]
      expect{
        Charma::ScatterChart.new(series:[{xy:xy}], unexpected:"value")
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if series has unexpected key" do
      xy = [[1,2],[3,4],[5,6]]
      expect{
        Charma::ScatterChart.new(series:[{xy:xy, unexpected:"value"}])
      }.to raise_error( Charma::Errors::InvalidOption )
    end
  end
  
  describe "#chart_type" do
    it "returns :scatter_chart" do
      c = Charma::ScatterChart.new(
        series:[{xy: [[3, 1], [4, 1], [5, 9], [2, 6], [5, 3], [5, 8], [9, 7]]}]
      )
      expect(c.chart_type).to eq(:scatter_chart)
    end
  end
end
