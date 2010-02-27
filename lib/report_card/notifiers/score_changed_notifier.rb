module ReportCard
  module Notifiers
    class ScoreChangedNotifier < ReportCard::Notifier
      def initialize(project, config, scoreboard)
        super(project, config)
        @urls       = config['score_changed_urls'] || []
        @scoreboard = scoreboard
      end

      def payload
        {
          :message    => "Scores for #{@project.name} has changed!",
          :scoreboard => @scoreboard
        }.to_json
      end
    end
  end
end