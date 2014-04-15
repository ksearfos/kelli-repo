# passed testing 4/15
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe "RecordComparer" do
  
  it_behaves_like "RecordComparer"

end