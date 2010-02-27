module ReportCard
  module Notifiers
    class ScoreChangedNotifier < ReportCard::Notifier
      def initialize(project, config, scores, old_scores)
        super(project, config)
        @urls       = config['score_changed_urls'] || []
        @scores     = scores
        @old_scores = old_scores
      end

      def payload
        {
          :message    => "Scores for #{@project.name} has changed!",
          :scores     => @scores,
          :old_scores => @old_scores,
          :scoreboard => scoreboard
        }.to_json
      end

      def scoreboard
        scores = ""
        columns = "%15s%20s%20s\n"
        scores << sprintf(columns, "", "This Run", "Last Run")
        scores << sprintf(columns, "Flay Score", @scores[:flay], @old_scores[:flay])
        scores << sprintf(columns, "Flog Total/Avg", "#{@scores[:flog_total]}/#{@scores[:flog_average]}", "#{@old_scores[:flog_total]}/#{@old_scores[:flog_average]}")
        scores << sprintf(columns, "Reek Smells", @scores[:reek], @old_scores[:reek])
        scores << sprintf(columns, "Roodi Problems", @scores[:roodi], @old_scores[:roodi])
      end
    end
  end
end