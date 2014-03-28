#!/bin/env ruby

require 'lib/RecordComparer'
require 'lib/extended_base_classes'
require 'lib/HL7CSV'
require 'logger'
  
def run_record_comparer( output_file, messages, final, set_size = 1 )
  type = messages[0].type   
  additional_fields = { sending_facility:"msh3" } 
  add_dynamic_fields_for_type( messages, type ) 
  add_dynamic_fields( messages, type, additional_fields )

  comparer = RecordComparer.new( messages, type, set_size )
  comparer.analyze
  $logger.info "Finished running record comparer. #{comparer.chosen.size} records required."   
  # DEBUG(comparer)

  if final
    log_final_results( comparer, $logger )
    save_results( output_file, comparer.chosen )
  else
    $logger.info "Writing to #{file}...\n"
    write_temporary_results( comparer, output_file )
  end
end

def add_dynamic_fields_for_type( messages, message_type )
  criteria_to_add = OHProcs.const_get( "#{message_type.upcase}_FIELDS_TO_ADD" )  
  add_dynamic_fields( messages, message_type, criteria_to_add )
end

def add_dynamic_fields( messages, message_type, criteria_to_add )
  OHProcs.add_criteria_to_list( messages, criteria_to_add, message_type )
end
  
def save_results( csv_file, recs )
  HL7CSV.records_to_spreadsheet( csv_file, recs )
  $logger.info "See #{csv_file}\n"
end

def write_temporary_results( comparer, temp_file )
  write_file = File.open( temp_file, "a+" )
  comparer.chosen.each{ |record| write_file.puts record.to_s }
  write_file.close  
end

def log_final_results( comparer, logger )
  fluff = '=' * 10
  matched = comparer.matched.unshift( "#{fluff} MATCHED #{fluff}" )
  unmatched = comparer.unmatched.unshift( "#{fluff} UNMATCHED #{fluff}" )

  # log completion in the logger
  logger.info comparer.summary
  logger.info "Criteria checked:\n#{[matched,unmatched].make_table}\n"  
end

def DEBUG( comparer )
  $logger.info comparer.summary ###DEBUG
  $logger.info comparer.matched ###DEBUG
end