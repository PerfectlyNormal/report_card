$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), "lib"))
require 'init'
require 'report_card'

run ReportCard::App