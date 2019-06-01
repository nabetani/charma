# frozen_string_literal: true

module Charma
  def self.named_validator( name, &proc )
    a=proc
    a.define_singleton_method(:to_s){ name }
    a
  end

  PositiveInteger = named_validator("positive integer") do |x|
    x.respond_to?(:to_i) && x.to_i == x && 0<x
  end

  def self.split_enumerable(e, &block)
    e.each.with_object([[]]) do |o, r|
      if block.call(o)
        r.push([])
      else
        r.last.push(o)
      end
    end
  end
end
