#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'
require 'lib/extended_base_classes'

FILE = "C:/Users/Owner/Documents/enc_post.dat"

col1 = [ "BOOKS", "Harry Potter", "The Domesday Book", "Snuff" ]
col2 = [ "MUSIC", "Les Mis", "Chess", "Yellow Submarine", "Hair" ]
t = [col1,col2].make_table
puts t

