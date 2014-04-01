require 'logger'

module TestRunnerMixins
  
  module Logging   # adds @logger, @logger_directory, @logger_file
    
  def create_logger( args={} )
    args.each_pair{ |variable,value|
      self.instance_variable_set( "@logger_#{variable}", value)
    }
    raise "Must set directory and file before a new Logger can be created!" unless @logger_directory && @logger_file
         
    create_log_directory
    @logger = Logger.new( @logger_file )
    format_logger
  end
    
  # it may seem redundant, but I do just a tiny bit of formatting in here
  def log( message, type = :info )
    case type
    when :error then @logger.error message.upcase
    when :child_message then @logger.info "== " + message
    when :standalone then @logger.info message
    when :emphatic then @logger.info "!!! #{message} !!!"
    else @logger.info "\n" + message
    end
  end

  def log( *args )
    self.class.log( *args )
  end
    
  def sign_off
    log "Exiting..."
    @logger.close
  end  

  private
    
  # called by run_setup
  def create_log_directory
    `mkdir "#{@logger_directory}"` unless File.exists?( @logger_directory )
  end

  # called run_setup
  def format_logger 
    @logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
    @logger.formatter = Proc.new{ |severity,datetime,prog,msg|
      str = "#{datetime} #{severity}: #{msg}\n"
      str
    }
  end 

  end
   
end