module ReportCard
  module Notifiers
    class GradedNotifier < ReportCard::Notifier
      include ReportCard::Helpers::Urls

      def initialize(project, config)
        super(project, config)
        @urls = config['graded_urls'] || []
      end

      def payload
        path = @project.public ? "" : "private"
        {
          :project => @project.name,
          :url     => project_output_path(@project),
          :message => "New metrics generated for #{@project.name}"
        }.to_json
      end
    end
  end
end