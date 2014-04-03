require 'logger'

class CustomizedLogger < Logger
  attr_reader :directory, :file  
    
  def initialize(log_directory, log_file)
    @directory = log_directory
    @file = "#{@directory}/#{log_file}"
         
    create_log_directory
    super(@file)
    format_logger
  end
  
  def error(message)
    super "!!! #{message.upcase} !!!"
  end
 
  def warn(message)
    info "#{message.upcase}!"
  end
    
  def child(message)
    info "== #{message.downcase}"
  end

  def section(message)
    modified_message = "#{message[0].downcase}#{message [1..-1]}"
    info "\n#{modified_message}"
  end
    
  def close
    info "Exiting..."
    close
  end  

  private
    
  # called by initialize
  def create_log_directory
    `mkdir "#{@directory}"` unless File.exists?(@directory)
  end

  # called initialize
  def format_logger 
    datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    formatter = Proc.new do |severity,datetime,prog,msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
  end
   
end