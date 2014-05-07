class ComparisonResult < Struct.new(:set_size, :criteria_size, :subset_sizes, :matched_criteria_sizes)
  # convenience methods for the multi-value attributes, for cases where
  #+ there is only one value and we want symmetry with the other attribute names
  def subset_size
    subset_sizes.first
  end
  
  def matched_criteria_size
    matched_criteria_sizes.first
  end
end