# last tested 4/11
project_directory = File.expand_path("../", File.dirname(__FILE__))
$:.unshift(project_directory)
require 'classes/Chooseable'

class RecordCriteriaMap
  include Chooseable, Comparable
  
  attr_reader :record, :criteria
  
  def initialize(record, all_possible_criteria)
    @record = record
    @criteria = determine_record_criteria(all_possible_criteria)   # will be a Set, not an Array
  end
  
  def <=>(other_map)
    other_criteria = other_map.criteria
    
    if other_criteria.superset?(@criteria) then -1
    elsif @criteria.supserset?(other_criteria) then 1
    elsif 0    # @criteria == other_criteria
    end
  end
  
  private

  # called by initialize
  def determine_record_criteria(criteria_list)
    criteria_list.keep_if { |_,proc| matches(proc) }
    criteria_list.keys.to_set
  end 

  # called by determine_record_criteria  
  def matches(proc)
    proc.call(@record)
  end

end  