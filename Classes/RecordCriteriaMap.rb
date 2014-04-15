# last tested 4/15
require 'mixins/Chooseable'

class RecordCriteriaMap
  include Chooseable
  
  attr_reader :record, :criteria
  
  def initialize(record, all_possible_criteria)
    @record = record
    @criteria = determine_record_criteria(all_possible_criteria)   # will be a Set, not an Array
  end
  
  private

  # called by initialize
  def determine_record_criteria(criteria_list)
    criteria_list.keep_if { |_,proc| satisfies_criterion?(proc) }
    criteria_list.keys
  end 

  # called by determine_record_criteria  
  def satisfies_criterion?(proc)
    proc.call(@record)
  end

end  