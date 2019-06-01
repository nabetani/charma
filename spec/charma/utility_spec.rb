# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Charma utilities" do
  describe "Charma.split_enumerable" do
    [
      {input:[1,2,nil,3,4], expected:[[1,2],[3,4]]},
      {input:[1,2,nil,3,4,nil,5,6,7,8,nil,9], expected:[[1,2],[3,4],[5,6,7,8],[9]]},
    ].each do |input:, expected:|
      it "splits #{input.inspect} into #{expected.inspect}" do
        actual = Charma.split_enumerable(input,&:nil?)
        expect(actual).to eq( expected )
      end
      it "splits #{input.inspect}.each into #{expected.inspect}" do
        actual = Charma.split_enumerable(input.each,&:nil?)
        expect(actual).to eq( expected )
      end
    end
  end
end
