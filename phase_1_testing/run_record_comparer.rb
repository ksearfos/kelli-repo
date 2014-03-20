#!/bin/env ruby

require "Record_Comparer/RecordComparer.rb"
require "Record_Comparer/OHProcs.rb"
require 'logger'

def run_record_comparer( results_file, messages )
  type = messages[0].type  
  var = OHProcs.instance_variable_get( "@#{type}" )
  if type == :adt
    OHProcs.define_group( "pv110", HL7Test.get_data(messages,"pv110"), :hostpial_service )   
    var.merge!( OHProcs::PV110_VALS )    
  else    
    OHProcs.define_group( "obr4", HL7Test.get_data(messages,"obr4"), :procedure_id )   
    var.merge!( OHProcs::OBR4_VALS )
  end
  
  # $logger.datetime_format = "%H:%M:%S.%L"   # HH:MM:SS
  # $logger.formatter = Proc.new{ |severity,datetime,prog,msg|
    # str = "#{datetime} #{severity}"
    # str << "(#{prog})" if prog
    # str << ":\n"
    # str << " #{msg}\n\n"
    # str
  # }

  comparer = RecordComparer.new( messages, type )
  comparer.analyze

  # the following goes into results_file
  File.open( results_file, "w" ) { |f|
    f.puts "==========MATCHED=========="
    f.puts comparer.matched
    f.puts ""
    f.puts "==========UNMATCHED=========="
    f.puts comparer.unmatched
    f.puts ""
    f.puts "==========RECORDS=========="
    f.puts comparer.used_records
  }

  # log completion in the logger
  $logger.info comparer.summary
  $logger.info "Record search completed.\n Results can be viewed in #{results_file}."
  
end