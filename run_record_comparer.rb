#!/bin/env ruby

require 'lib/RecordComparer'
require 'lib/extended_base_classes'
require 'lib/HL7CSV'
require 'logger'

LIMIT_SERIES_ENCOUNTERS = Proc.new{ |recs| 
    series = []
    nonseries = []
    recs.each{ |rec| OHProcs::SERIES_ENC.call(rec) ? series << rec : nonseries << rec }
    target_amount = recs.size * 0.02
    nonseries + series.take(target_amount)
  }
  
def run_record_comparer( file, messages, final, set_size = 1 )
  type = messages[0].type    
  add_dynamic_fields( messages, type ) 
  
  # make new record comparer
  comparer = RecordComparer.new( messages, type, set_size )
  # comparer.weight_method = LIMIT_SERIES_ENCOUNTERS
  comparer.analyze
  $logger.info "Finished running record comparer. #{comparer.chosen.size} records required."   
  $logger.info comparer.summary ###DEBUG
  $logger.info comparer.matched ###DEBUG
  if final  
    fluff = '=' * 10
    matched = comparer.matched.unshift( "#{fluff} MATCHED #{fluff}" )
    unmatched = comparer.unmatched.unshift( "#{fluff} UNMATCHED #{fluff}" )

    # log completion in the logger
    $logger.info comparer.summary
    $logger.info "Criteria checked:\n#{[matched,unmatched].make_table}\n"  
    save_results( file, comparer.chosen )
  else
    $logger.info "Writing to #{file}...\n"
    write_file = File.open( file, "a+" )
    comparer.chosen.each{ |record| write_file.puts record.to_s }
    write_file.close
  end
end

def add_dynamic_fields( messages, type )
  fields = OHProcs.const_get( "#{type.upcase}_FIELDS_TO_ADD" )  # criteria to add
  var = OHProcs.instance_variable_get( "@#{type}" )             # all criteria
  
  # add our new criteria to the list of all criteria
  # need to make new groups first, of course
  fields.each{ |id,field| var.merge! OHProcs.define_group(field, HL7.get_data(messages,field), id) }
end

def save_results( csv_file, recs )
  HL7CSV.records_to_spreadsheet( csv_file, recs )
  $logger.info "See #{csv_file}\n"
end
