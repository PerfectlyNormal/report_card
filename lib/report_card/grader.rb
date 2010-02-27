module ReportCard
  class Grader
    attr_reader :project, :config, :scores, :old_scores

    def initialize(project, config)
      @project = project
      @config  = config
    end

    def grade
      return unless ready?
      configure
      generate
      wrapup if success?
    end

    def wrapup
      score
      notify
    end

    def ready?
      repo = Integrity::Repository.new(project.builds.last.id, project.uri, project.branch, project.builds.last.commit.identifier).directory
      dir  = ReportCard.config['integrity_path'] + '/' + repo

      if File.exist?(dir)
        ReportCard.log "Building metrics for #{project.name}"
        Dir.chdir dir
      else
        ReportCard.log "Skipping, directory does not exist: #{dir}"
      end
    end

    def configure
      ENV['CC_BUILD_ARTIFACTS'] = self.output_path
      MetricFu::Configuration.run do |config|
        config.reset
        config.data_directory = self.archive_path
        config.template_class = AwesomeTemplate
        config.metrics = config.graphs = [:flog, :flay, :rcov, :reek, :roodi]
        config.rcov     = { :test_files => ['test/**/*_test.rb', 'spec/**/*_spec.rb'],
                            :rcov_opts  => ["--sort coverage",
                            "--no-html",
                            "--text-coverage",
                            "--no-color",
                            "--profile",
                            "--rails",
                            "--include test",
                            "--exclude /gems/,/usr/local/lib/site_ruby/1.8/,spec"]}
      end
      MetricFu.report.instance_variable_set(:@report_hash, {})
    end

    def generate
      begin
        MetricFu.metrics.each { |metric| MetricFu.report.add(metric) }
        MetricFu.graphs.each  { |graph| MetricFu.graph.add(graph, :bluff) }

        MetricFu.report.save_output(MetricFu.report.to_yaml, MetricFu.base_directory, 'report.yml')
        MetricFu.report.save_output(MetricFu.report.to_yaml, MetricFu.data_directory, "#{Time.now.strftime("%Y%m%d")}.yml")
        MetricFu.report.save_templatized_report

        MetricFu.graph.generate

        @success = true
      rescue Exception => e
        ReportCard.log "Problem generating the reports: #{e}", :level => :error
        @success = false
      end
    end

    def score
      report = YAML.load_file(File.join(MetricFu.base_directory, 'report.yml'))

      @scores = {
        :flay         => report[:flay][:total_score].to_s,
        :flog_total   => report[:flog][:total].to_s,
        :flog_average => report[:flog][:average].to_s,
        :reek         => report[:reek][:matches].inject(0) { |sum, match| sum + match[:code_smells].size }.to_s,
        :roodi        => report[:roodi][:problems].size.to_s
      }

      @scores[:rcov] = report[:rcov][:global_percent_run].to_s if report.has_key?(:rcov)

      if File.exist?(self.scores_path)
        @old_scores = YAML.load_file(self.scores_path)
      else
        FileUtils.mkdir_p(File.dirname(self.scores_path))
        @old_scores = {}
      end

      File.open(self.scores_path, "w") do |f|
        f.write @scores.to_yaml
      end
    end

    def notify
      return if @config['skip_notification']

      graded = Notifiers::GradedNotifier.new(@project, @config)
      graded.deliver!

      if score_changed?
        score = Notifiers::ScoreChangedNotifier.new(@project, @config, scores, old_scores)
        score.deliver!
      end

      true
    end

    def score_changed?
      self.scores != self.old_scores
    end

    def success?
      @success
    end

    def data_path(*dirs)
      data_dir = @config['data_dir'] || File.join(File.dirname(__FILE__), "..", "..", "data")
      File.expand_path(File.join(data_dir, *dirs))
    end

    def site_path(*dirs)
      site_dir = @config['site'] || File.join(File.dirname(__FILE__), "..", "..", "public")
      File.expand_path(File.join(site_dir, *dirs))
    end

    def output_path
      path = [@project.name]
      path.unshift("private") unless @project.public
      site_path(*path)
    end

    def scores_path
      data_path("scores", @project.name)
    end

    def archive_path
      data_path("archive", @project.name)
    end
  end
end
