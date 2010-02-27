require 'report_card/core_ext/kernel'
require 'report_card/helpers'
require 'report_card/app'
require 'report_card/grader'

module ReportCard
  CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), "..", "config.yml"))

  class << self
    attr_accessor :logger
  end

  def self.setup
    require config['integrity_path'] + '/init.rb'
    ReportCard.logger = Logger.new(config['log'] || STDERR)
    ReportCard.logger.formatter = Logger::Formatter.new # So we get some timestamps as well. Always nice to have
  end

  def self.log(message, level = :info)
    level = :info unless [:debug, :info, :warn, :error, :fatal, :unknown].include?(level)
    logger.send(level, message)
  end

  def self.config
    if File.exist?(CONFIG_FILE)
      @config ||= YAML.load_file(CONFIG_FILE)
    else
      Kernel.abort("You need a config file at #{CONFIG_FILE}. Check the readme please!")
    end
  end
end

ReportCard.setup