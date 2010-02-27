module ReportCard
  class Notifier
    def initialize(project, config)
      @project = project
      @config  = config
    end

    def deliver!
      ReportCard.log "Sending #{self.class} for #{@project.name}"
      @urls.each do |url|
        Net::HTTP.post_form(URI.parse(url), {"payload" => payload})
      end
    end

    def payload
      {}.to_json
    end
  end
end