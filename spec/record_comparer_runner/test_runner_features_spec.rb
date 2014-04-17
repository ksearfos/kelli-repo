$LOAD_PATH.unshift File.dirname(__FILE__)
require 'spec_helper'
require 'shared_examples'

describe TestRunner do
  it_behaves_like TestRunner do
    type = :record_type
    let(:record_type) { type }
    let(:runner) { TestRunner.new(type) }
  end
end