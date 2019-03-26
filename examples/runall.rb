# frozen_string_literal: true

Dir.glob( "*.rb" ) do |fn|
  next if /runall\.rb/===fn
  %x( bundle exec ruby #{fn} )
end
