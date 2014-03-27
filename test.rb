#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/extended_base_classes'

hash = { 1=>2, 3=>4, 5=>6, 7=>8 }
hash.update_values!{ 10 }
puts hash
hash.update_values!{ |_,v| v - 1 }
puts hash
hash.update_values!{ |k| k }
puts hash