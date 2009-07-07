require 'integrity'

class Pythagoras
  CONFIG_FILE = "config.yml"
  attr_reader :project, :config

  def initialize(project, config)
    @project = project
    @config = config
  end

  def ready?
    dir = Integrity::ProjectBuilder.new(project).send(:export_directory)
    if File.exist?(dir)
      Dir.chdir dir
    else
      STDERR.puts ">> Skipping, directory does not exist: #{dir}"
    end
  end

  def output_path
    path = [@project.name]
    path.unshift("private") unless @project.public
    File.expand_path(File.join(__FILE__, "..", "..", "_site", *path))
  end

  def self.run
    begin
      config = YAML.load_file(CONFIG_FILE)
    rescue Exception => e
      STDERR.puts "There was a problem reading your #{CONFIG_FILE} file: #{e}"
      return
    end

    if config
      Integrity.new(config[:integrity_config])
    else
      STDERR.puts "Your config file is blank."
      return
    end

    ignore = config[:ignore] ? Regexp.new(config[:ignore]) : /[^\w\d\s]+/

    begin
      Integrity::Project.all.each do |project|
        Pythagoras.new(project, config) if project.name !~ ignore
      end
    rescue Exception => e
      STDERR.puts "There was a problem loading your projects from integrity: #{e}"
      return
    end
  end
end
