#!/bin/env ruby

proj_dir = File.expand_path( "../..", __FILE__ )
require "#{proj_dir}/lib/extended_base_classes.rb"
require "#{proj_dir}/hl7module/HL7.rb"

FILE = "#{proj_dir}/resources/manifest_lab_short_unix.txt"
# FILE = "C:/Users/Owner/Documents/manifest_lab_out_shortened.txt"
# FILE = "C:/Users/Owner/Documents/manifest_rad_out_shortened.txt"

cl1 = HL7Test::SegmentEigenclass.new

HL7Test.new_typed_segment( :PID )
HL7Test.new_typed_segment( :PV1 )
pid = Pid.new
pv1 = Pv1.new
pv2 = Pv1.new
puts Pv1.field_index_maps, "--"
Pv1.add(:apple,4)
puts pv1.type, pv2.type
puts pv1.field_index_maps, pv2.field_index_maps
pv2.add(:banana,5)
puts pv1.field_index_maps, pv2.field_index_maps
puts HL7Test::SegmentEigenclass.type ? "yes" : "no"
