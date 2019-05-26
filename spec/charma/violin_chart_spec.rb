# frozen_string_literal: true

require 'spec_helper'


module ViolinChartSpecHelper
end

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
        y_title:"Y TITLE"
      )
      expect(c[:title]).to eq( "TITLE" )
      expect(c[:series]).to eq( [S0,S1] )
      expect(c[:x_ticks]).to eq( %w(foo bar baz) )
      expect(c[:x_title]).to eq( "X TITLE")
      expect(c[:y_title]).to eq( "Y TITLE")
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
    it "raises if series.y2 is NOT Array of Numeric" do
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}, {y2:[[1]]}]})
      }.not_to raise_error
      pat = /(Series\.y2\s)|(\sy2\s)/
      # array of numeric
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}, {y2:[1]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )

      # array of array of ( numeric and string )
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}, {y2:[[1,""]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )

      # array of ( array of numeric and array of string )
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}, {y2:[[1], [""]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )

      # array of array of array of numeric
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]]}, {y2:[[[1]]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, pat )
    end
    it "raises if a series has both y and y2" do
      expect{
        Charma::ViolinChart.new({series:[{y:[[2]], y2:[[1]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, /both y and y2/ )
    end

    it "raises if no series has y" do
      expect{
        Charma::ViolinChart.new({series:[{y2:[[1]]}, {y2:[[1]]}]})
      }.to raise_error( Charma::Errors::InvalidOption, /At least one series has y/ )
    end

    it "raises if there is unexpected key" do
      expect{
        Charma::ViolinChart.new(series:[{y:[[1]], unexpected:1}], unexpected:"value")
      }.to raise_error( Charma::Errors::InvalidOption, /is not valid key/ )
    end

    it "raises if series has unexpected key" do
      expect{
        Charma::ViolinChart.new({series:[{y:[[1]], unexpected:1}]})
      }.to raise_error( Charma::Errors::InvalidOption, /is not valid key/ )
    end
  end
end