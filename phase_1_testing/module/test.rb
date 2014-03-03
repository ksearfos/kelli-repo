#!/bin/env ruby

proj_dir = File.expand_path( "../..", __FILE__ )
FILE = "#{proj_dir}/resources/manifest_lab_out_short"
$seg = "PID|||00487630^^^ST01||Thompson^Richard^L||19641230|M|||^^^^^^^|||||||A2057219^^^^STARACC|291668118"
$segs = "OBX||TX|APRESULT^.^LA01|1|.||||||F\nOBX||TX|APRESULT^.^LA01|2|  REPORT||||||F"
$field = "Thompson^Richard^L^III"

require "#{proj_dir}/module/HL7"

segment = HL7::Segment.new( $segs, "OBX" )
puts segment.fields #, segment.lines, segment.full_text, segment.number_of_lines, segment.type
segment.view_fields