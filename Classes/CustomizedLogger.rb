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
    info "-- #{message.downcase}"
  end

  def parent(message)
    self << "\n"
    modified_message = "#{message[0].downcase}#{message [1..-1]}"
    info "#{modified_message}"
  end
    
  def close
    info "Exiting..."
    super
  end  

  private
    
  # called by initialize
  def create_log_directory
    `mkdir "#{@directory}"` unless File.exists?(@directory)
  end

  # called initialize
  def format_logger 
    self.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    self.formatter = Proc.new do |severity,datetime,prog,msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
  end
   
end