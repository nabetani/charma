# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::BarChart do
  describe "BarChart behavior" do
    it "will raise if no series" do
      expect{
        Charma::BarChart.new({})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "will raise unless series is Array of Hash" do
      expect{
        Charma::BarChart.new({series:123})
      }.to raise_error( Charma::Errors::InvalidOption )
      expect{
        Charma::BarChart.new({series:[1]})
      }.to raise_error( Charma::Errors::InvalidOption )
      expect{
        Charma::BarChart.new({series:[{y:[1]},123]})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "will raise if series is empty" do
      expect{
        Charma::BarChart.new({series:[]})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "will raise if series.y is NOT Array of Numeric" do
      expect{
        Charma::BarChart.new({series:[{y:[1]}]})
      }.not_to raise_error

      expect{
        Charma::BarChart.new({series:[{y:[1,:a]}]})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "will raise if series has unexpected key" do
      expect{
        Charma::BarChart.new({series:[{y:[1], unexpected:1}]})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "will raise unless x_ticks are Array or nil" do
      expect{
        Charma::BarChart.new({x_ticks:["a"], series:[{y:[1]}]})
      }.not_to raise_error

      expect{
        Charma::BarChart.new({x_ticks:"a", series:[{y:[1]}]})
      }.to raise_error( Charma::Errors::InvalidOption )

      expect{
        Charma::BarChart.new({x_ticks:[1], series:[{y:[1]}]})
      }.not_to raise_error
    end
  end

  describe "#chart_type" do
    it "returns :bar_chart" do
      c = Charma::BarChart.new({series:[{y:[1]}]})
      expect(c.chart_type).to eq(:bar_chart)
    end
  end
end
