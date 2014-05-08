require 'utility_methods'
require 'logger'

module Loggable
  TIMESTAMP = Time.now.strftime "%H%M_%m-%d-%Y"      # HHMM_MM-DD-YYYY

  def class_name
    clazz = self.class.name
    clazz.gsub!(/([A-Z])/, '_\1')
    "run#{clazz.downcase}"
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
    clear_directory(@log_directory)
    reroute_stdout(@log_file) if write_stdout_to_log_file
    @logger = Logger.new(@log_file)
    format_logger
  end

  def format_logger
    @logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    @logger.formatter = Proc.new do |severity,datetime,prog,msg|
      str = "\n#{datetime} #{severity}: #{msg}"
      str
    end
  end
  
  def write_as_parent(message)
    @logger.info "#{message}"
  end
  
  def write_as_child(message)
    @logger.info " -- #{message.downcase}"
  end
  
  def write_as_error(message)
    @logger.error "!! ERROR: #{message.upcase} !!"
  end
end