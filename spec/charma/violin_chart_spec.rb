# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::ViolinChart do
  S0, S1 = Array.new(2) do |s|
    values = Array.new(3) do |x|
      m = Math.sin(x*19+13)
      d = Math.cos(x*23+29)
      Array.new(100) do |dix|
        ((dix-25)/50.0)**3
      end
    end
    { name: "series #{s}", y:values }
  end
  describe ".new" do
    it "creates ViolinChart with parameters" do
      c = Charma::ViolinChart.new(
        title:"TITLE",
        series:[S0,S1],
        x_ticks:%w(foo bar baz),
        x_title:"X TITLE",
        y_title:"Y TITLE",
        bins:30
      )
      expect(c[:title]).to eq( "TITLE" )
      expect(c[:series]).to eq( [S0,S1] )
      expect(c[:x_ticks]).to eq( %w(foo bar baz) )
      expect(c[:x_title]).to eq( "X TITLE")
      expect(c[:y_title]).to eq( "Y TITLE")
      expect(c[:bins]).to eq(30)
    end

    it "raises if no series" do
      expect{
        Charma::ViolinChart.new({})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises unless series is Array of Hash" do
      expect{
        Charma::ViolinChart.new({series:123})
      }.to raise_error( Charma::Errors::InvalidOption )
      expect{
        Charma::ViolinChart.new({series:[1]})
      }.to raise_error( Charma::Errors::InvalidOption )
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]},123]})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if series is empty" do
      expect{
        Charma::ViolinChart.new({series:[]})
      }.to raise_error( Charma::Errors::InvalidOption )
    end

    it "raises if series.y is NOT Array of Array of Numeric" do
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}]})
      }.not_to raise_error
      pat = /(Series\.y\s)|(\sy\s)/
      # array of numeric
      expect{
        Charma::ViolinChart.new({series:[{y:[1]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )

      # array of array of ( numeric and string )
      expect{
        Charma::ViolinChart.new({series:[{y:[[1,""]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )

      # array of ( array of numeric and array of string )
      expect{
        Charma::ViolinChart.new({series:[{y:[[1], [""]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )

      # array of array of array of numeric
      expect{
        Charma::ViolinChart.new({series:[{y:[[[1]]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )
    end

    it "raises if there is unexpected key" do
      expect{
        Charma::ViolinChart.new(series:[{y:[[1]], unexpected:1}], unexpected:"value")
      }.to raise_error( Charma::Errors::InvalidOption, /is not valid key/ )
    end

    it "raises if series has unexpected key" do
      expect{
        Charma::ViolinChart.new(series:[{y:[[1]], unexpected:1}])
      }.to raise_error( Charma::Errors::InvalidOption, /is not valid key/ )

      # violin chart does not accept y2
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}, {y2:[[1]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, /is not valid key/ )
    end

    it "raises unless x_ticks are Array or nil" do
      expect{
        Charma::ViolinChart.new(x_ticks:["a"], series:[{y:[[1]]}])
      }.not_to raise_error

      expect{
        Charma::ViolinChart.new(x_ticks:"a", series:[{y:[[1]]}])
      }.to raise_error( Charma::Errors::InvalidOption, /x_ticks/ )

      expect{
        Charma::ViolinChart.new(x_ticks:[1], series:[{y:[[1]]}])
      }.not_to raise_error
    end

    describe "bins property" do
      [
        { bins:10 },
        { bins:12.0 }, # accept Float if the value is integer
        { bins:15r }, # accept Rational if the value is integer
      ].each do |bins:|
        it "does not raise if bins is #{bins}" do
          expect{
            Charma::ViolinChart.new(bins:bins, series:[{y:[[1]]}])
          }.not_to raise_error
        end
      end

      [
        { bins:0, pat:/should be positive integer/ },
        { bins:12.5, pat:/should be positive integer/ },
        { bins:15.6r, pat:/should be positive integer/ },
        { bins:-12.5, pat:/should be positive integer/ },
        { bins:-15.6r, pat:/should be positive integer/ },
      ].each do |bins:, pat:|
        it "raises if bins is #{bins}" do
          expect{
            Charma::ViolinChart.new(bins:bins, series:[{y:[[1]]}])
          }.to raise_error( Charma::Errors::InvalidOption, pat )
        end
      end
    end
  end

  describe "#chart_type" do
    it "returns :violin_chart" do
      c = Charma::ViolinChart.new(series:[{y:[[1]]}])
      expect(c.chart_type).to eq(:violin_chart)
    end
  end

  describe "#y2?" do
    it "returns false" do
      c = Charma::ViolinChart.new(series:[{y:[[1]]}])
      expect(c.y2?).to be false
    end
  end

  describe "#bins" do
    it "returns 100 unless bins is not specified" do
      c = Charma::ViolinChart.new(series:[{y:[[1]]}])
      expect(c.bins).to be 100
    end

    it "returns specified value" do
      c = Charma::ViolinChart.new(bins:1234, series:[{y:[[1]]}])
      expect(c.bins).to be 1234
    end
  end
end
