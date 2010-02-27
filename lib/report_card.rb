$:.unshift(File.dirname(__FILE__))

require 'report_card/core_ext/kernel'
require 'report_card/helpers'
require 'report_card/app'
require 'report_card/index'
require 'report_card/grader'

module ReportCard
  CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), "..", "config.yml"))

  def self.grade
    self.setup
    require config['integrity_path'] + '/init.rb'

    ignore = config['ignore'] ? Regexp.new(config['ignore']) : /[^\w\d\s\S]+/
    projects = []

    Integrity::Project.all.each do |project|
      if project.name !~ ignore
        grader = Grader.new(project, config)
        grader.grade
        projects << project if grader.success?
      end
    end

    Index.create(projects, config['site']) unless projects.empty?
  end

  def self.config
    if File.exist?(CONFIG_FILE)
      @config ||= YAML.load_file(CONFIG_FILE)
    else
      Kernel.abort("You need a config file at #{CONFIG_FILE}. Check the readme please!")
    end
  end

  def self.setup
    FileUtils.mkdir_p(config['site'])
    FileUtils.cp(Dir[File.join(File.dirname(__FILE__), '..', 'template', '*.{css,ico}')], config['site'])
  end
end
