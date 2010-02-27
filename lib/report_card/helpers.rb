require 'report_card/helpers/authorization'
require 'report_card/helpers/rendering'
require 'report_card/helpers/urls'

module ReportCard
  module Helpers
    include Authorization
    include Rendering
    include Urls

    include Rack::Utils
    alias :h :escape_html
  end
end