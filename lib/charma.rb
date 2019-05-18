# frozen_string_literal: true

require "prawn"
require_relative "charma/version"
require_relative "charma/error"

require_relative "charma/constants"
require_relative "charma/rect"
require_relative "charma/chart"

require_relative "charma/bar_chart"
require_relative "charma/scatter_chart"

require_relative "charma/page"
require_relative "charma/document"

require_relative "charma/renderer"
require_relative "charma/pdf_renderer"
require_relative "charma/pdf_canvas"
require_relative "charma/chart_renderer"
require_relative "charma/barchart_renderer"
require_relative "charma/scatterchart_renderer"
