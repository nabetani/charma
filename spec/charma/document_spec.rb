# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Charma::Document do
  describe ".new" do
    it "creates Document with no parameter" do
      doc = nil
      expect{ doc = Charma::Document.new }.not_to raise_error
      page = doc.add_page()
      expect( page.size ).to eq( 210.0+297.0i )
      expect( page.font ).to be_nil
    end

    it "raises if there is unexpected parameter" do
      expect{ 
        Charma::Document.new( unexpected: :foo )
      }.to raise_error( ArgumentError )
    end

    it "raises if page_layout is unexpected" do
      expect{ 
        Charma::Document.new( page_layout: :foo )
      }.to raise_error( Charma::Errors::InvalidOption )
    end
  end
  describe "#render" do
    it "raises if unexpected file type" do
      doc = Charma::Document.new
      doc.add_page do |page|
        page.add_chart( Charma::BarChart.new(
          series:[{y:[1]}]
        ))
      end
      expect{
        doc.render( "hoge.docx" )
      }.to raise_error( Charma::Errors::InvalidFileType )
      expect{
        doc.render( "hoge.docx", file_type: :docx )
      }.to raise_error( Charma::Errors::InvalidFileType )
    end
    it "raises if no page" do
      doc = Charma::Document.new
      expect{
        doc.render( "hoge.pdf" )
      }.to raise_error( Charma::Errors::NothingToRender )
    end
    it "raises if page without chart" do
      doc = Charma::Document.new
      doc.add_page
      expect{
        doc.render( "hoge.pdf" )
      }.to raise_error( Charma::Errors::NothingToRender )
    end
    it "renders PDF" do
      pdf_fn = "#{SPEC_OUTPUT_DIR}/hoge.pdf"
      File.delete( pdf_fn ) if File.exist?( pdf_fn )
      FileUtils.mkdir_p( File.split(pdf_fn).first )
      expect( File.exist?( pdf_fn ) ).to be false
      doc = Charma::Document.new
      doc.add_page do |page|
        s=Array.new(7){ |x|
          { y: Array.new(11){ |y| 1+Math.sin((x+2)**(y+2)) } }
        }
        page.add_chart( Charma::BarChart.new(
          series:s
        ))
      end
      doc.render( pdf_fn )
      expect( File.exist?( pdf_fn ) ).to be true
    end
  end
end
