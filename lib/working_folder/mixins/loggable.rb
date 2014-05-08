require 'logger'
require 'fileutils'

module Loggable
  TIMESTAMP = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY

  def class_name
    clazz = self.class.name
    clazz.gsub!(/([A-Z])/, '_\1')
    clazz.downcase!
    "comparer_parse_file"   # TEST
  end
      
  def make_logger(parent_directory)
    @log_directory = "#{parent_directory}/logs"
    @log_file = "#{@log_directory}/#{TIMESTAMP}_#{class_name}.log"
    set_up_logger
  end
  
  def log(message, level = :parent)
    case level
    when :parent then write_as_parent(message)
    when :child then write_as_child(message)
    when :error then write_as_error(message)
    else @logger.info(message)
    end
  end
  
  private
  
  def set_up_logger(write_stdout_to_log_file = false)
    File.directory?(@log_directory) ? clear_directory : create_directory
    reroute_stdout if write_stdout_to_log_file
    @logger = Logger.new(@log_file)
    format_logger
  end

  def reroute_stdout
    $stdout = File.new(@log_file, "w")
  end

  def format_logger
    @logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    @logger.formatter = Proc.new do |severity,datetime,prog,msg|
      str = "#{datetime} #{severity}: #{msg}"
      str
    end
  end
  
  def clear_directory
    FileUtils.rm_r @log_directory
    create_directory
    # Dir.foreach(@log_directory) { |file| File.delete("#{@log_directory}/#{file}") }
  end
  
  def create_directory
    `mkdir "#{@log_directory}"`
  end
  
  def write_as_parent(message)
    @logger.info "\n#{message}"
  end
  
  def write_as_child(message)
    @logger.info " -- #{message.downcase}"
  end
  
  def write_as_error(message)
    @logger.error "!! ERROR: #{message.upcase} !!"
  end
end