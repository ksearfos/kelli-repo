require 'logger'

class CustomizedLogger < Logger
    
  def initialize( log_directory, log_file )
    @logger_directory = log_directory
    @logger_file = log_file
         
    create_log_directory
    super( @logger_file )
    format_logger
  end
    
  def directory
    @logger_directory
  end
  
  def file
    @logger_file
  end
  
  def error( message )
    super "!!! #{message.upcase} !!!"
  end
 
  def warn( message )
    info message.upcase + "!"
  end
    
  def add( message )
    info "== " + message.downcase
  end

  def section( message )
    modified_message = message[0].downcase + message [1..-1]
    info "\n" + modified_message
  end
    
  def close
    info "Exiting..."
    close
  end  

  private
    
  # called by initialize
  def create_log_directory
    `mkdir "#{@logger_directory}"` unless File.exists?( @logger_directory )
  end

  # called initialize
  def format_logger 
    datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    formatter = Proc.new{ |severity,datetime,prog,msg|
      str = "#{datetime} #{severity}: #{msg}\n"
      str
    }
  end
   
end