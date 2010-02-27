require 'report_card/core_ext/kernel'
require 'report_card/helpers'
require 'report_card/app'
require 'report_card/grader'

module ReportCard
  CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), "..", "config.yml"))

  def self.grade
    require config['integrity_path'] + '/init.rb'

    ignore = config['ignore'] ? Regexp.new(config['ignore']) : /[^\w\d\s\S]+/

    Integrity::Project.all.each do |project|
      if project.name !~ ignore
        grader = Grader.new(project, config)
        grader.grade
      end
    end
  end

  def self.config
    if File.exist?(CONFIG_FILE)
      @config ||= YAML.load_file(CONFIG_FILE)
    else
      Kernel.abort("You need a config file at #{CONFIG_FILE}. Check the readme please!")
    end
  end
end
