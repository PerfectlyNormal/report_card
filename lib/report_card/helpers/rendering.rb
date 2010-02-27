module ReportCard
  module Helpers
    module Rendering
      def show(view, options={})
        @title = options[:title]
        haml view
      end

      def stylesheets(*sheets)
        sheets.each { |sheet|
          haml_tag(:link, :href => path("/#{sheet}.css"),
            :type => "text/css", :rel => "stylesheet")
        }
      end
    end
  end
end