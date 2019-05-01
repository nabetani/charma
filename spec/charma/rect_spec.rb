# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::Rect do
  describe "#vsplit" do
    it "returns split rects" do
      rc = Charma::Rect.new( 10, 20, 30, 40 )
      s = rc.vsplit(1, 2, 3, 4)
      expect(s.size).to eq(4)
      expect(s[0]).to eq( Charma::Rect.new( 10, 20, 30, 4 ) )
      expect(s[1]).to eq( Charma::Rect.new( 10, 20+4, 30, 8 ) )
      expect(s[2]).to eq( Charma::Rect.new( 10, 20+4+8, 30, 12 ) )
      expect(s[3]).to eq( Charma::Rect.new( 10, 20+4+8+12, 30, 16 ) )
    end
  end

  describe "#hsplit" do
    it "returns split rects" do
      rc = Charma::Rect.new( 10, 20, 30, 40 )
      s = rc.hsplit(1, 2, 3, 4)
      expect(s.size).to eq(4)
      expect(s[0]).to eq( Charma::Rect.new( 10, 20, 3, 40 ) )
      expect(s[1]).to eq( Charma::Rect.new( 10+3, 20, 6, 40 ) )
      expect(s[2]).to eq( Charma::Rect.new( 10+3+6, 20, 9, 40 ) )
      expect(s[3]).to eq( Charma::Rect.new( 10+3+6+9, 20, 12, 40 ) )
    end
  end

  describe "#cx" do
    it "returns center x" do
      rc = Charma::Rect.new( 1, 10, 100, 1000 )
      expect(rc.cx).to eq( 51 )
    end
  end

  describe "#cy" do
    it "returns center y" do
      rc = Charma::Rect.new( 1, 10, 100, 1000 )
      expect(rc.cy).to eq( 510 )
    end
  end

  describe "#center" do
    it "returns center" do
      rc = Charma::Rect.new( 1, 10, 100, 1000 )
      expect(rc.center).to eq( [51, 510] )
    end
  end

  describe "#rot" do
    it "returns rotated rect" do
      cx = 1
      cy = 10
      w, h = 100, 1000
      rc = Charma::Rect.new( cx-w/2, cy-h/2, w, h )
      rotated = Charma::Rect.new( cx-h/2, cy-w/2, h, w )
      expect(rc.rot).to eq( rotated )
      expect(rotated.rot).to eq( rc )
    end
  end

  describe "accessors" do
    it "returns appropriate values" do
      rc = Charma::Rect.new( 1, 10, 100, 1000 )
      expect( rc.x ).to eq(1)
      expect( rc.y ).to eq(10)
      expect( rc.w ).to eq(100)
      expect( rc.h ).to eq(1000)
      expect( rc.right ).to eq(101)
      expect( rc.bottom ).to eq(1010)
    end
  end
end
