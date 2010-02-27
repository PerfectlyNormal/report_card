module ReportCard
  module Notifiers
    class GradedNotifier < ReportCard::Notifier
      def initialize(project, config)
        super(project, config)
        @urls = config['graded_urls'] || []
      end

      def payload
        path = @project.public ? "" : "private"
        {
          :project => @project.name,
          :url     => File.join(@config['url'], path, @project.name, 'output'), # FIXME: url generator?
          :message => "New metrics generated for #{@project.name}"
        }.to_json
      end
    end
  end
end