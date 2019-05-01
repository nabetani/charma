# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::Page do
  describe "Page behavior" do
    it "defaults appropriate values" do
      page = Charma::Page.new
      expect(page.font).to be nil
      expect(page.size).to eq(210.0+297.0i)
      expect(page.charts).to eq([])
      expect(page.w).to eq(210.0)
      expect(page.h).to eq(297.0)
    end

    [
      ["A4", 210, 297],
      ["A0", 841, 1189],
    ].each do |name, w, h|
      it "can recognize paper size #{name}" do
        page = Charma::Page.new( page_size: name )
        expect(page.w).to eq(w)
        expect(page.h).to eq(h)
        shorter, longer = [w,h].minmax
        la = Charma::Page.new( page_size: name, page_layout: :landscape )
        expect(la.w).to eq(longer)
        expect(la.h).to eq(shorter)
        po = Charma::Page.new( page_size: name, page_layout: :portrait )
        expect(po.w).to eq(shorter)
        expect(po.h).to eq(longer)
      end
    end

    it "raises exception if page size is unexpected" do
      expect{
        Charma::Page.new( page_size:"NO_SUCH_SIZE" )
      }.to raise_error(Charma::Errors::InvalidPageSize)
      expect{
        Charma::Page.new( page_size:"A999" )
      }.to raise_error(Charma::Errors::InvalidPageSize)
    end

    it "raises exception if page layout is unexpected" do
      expect{
        Charma::Page.new( page_layout: :no_such_layout )
      }.to raise_error(Charma::Errors::InvalidPageLayout)
    end
  end

  describe "#add_chart" do
    it "will add chart" do
      page = Charma::Page.new
      expect( page.charts.size ).to eq 0
      c0, c1, c2 = Array.new(3){ |ix|
        series = {name: "c#{ix}", y: [3, 1, 4, 1, 5, 9]}
        opts = { series:[series] }
        Charma::BarChart.new( opts )
      }
      page.add_chart( c0 )
      page.add_chart( c1 )
      page.add_chart( c2 )
      expect( page.charts.size ).to eq 3
      expect( page.charts[0] ).to be c0
      expect( page.charts[1] ).to be c1
      expect( page.charts[2] ).to be c2
    end
  end
end
