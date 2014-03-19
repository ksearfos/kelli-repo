#!/bin/env ruby

$LOAD_PATH.unshift File.dirname __FILE__    # phase_1_testing directory
require 'lib/hl7module/HL7'

FILE = "C:/Users/Owner/Documents/manifest_lab_out.txt"

# mh = HL7Test::MessageHandler.new FILE
# field = HL7Test.find_field( :units )
# u = HL7Test.get_data( mh.records, field )
# puts u.join( "', '" )
a = [ 'seconds', 'K/mcL', 'M/mcL', 'g/dL', '%', 'fL', 'PG', 'mmol/L', 'mg/dL', 'mL/min/1.73 m2', 'ng/mL',
            'U/L', 'pH units', '/lpf', '/hpf', 'mcIU/mL', 'mg/L', 'IU/mL', 'log IU/mL', 'mcg/mL FEU', 'ng/dL',
            'mlU/mL', 'mIU/mL', 'mcg/dL', 'pg/mL', 'mm/hr', 'U', 'titer', 'mg/g crea', 'mg/24 h', 'h', 'mL',
            'nmol/L', '/mcL', 'mm Hg', 'weeks', 'years', 'lbs', 'U/mL', 'g', 'mOsm/kg', 'mcg/mL', 'umol/L', 'nm',
            'mEq/L', '%/L', 'kU/L', 'g/24 hr', 'hours', 'nmol/mL', 'L/min', 'mOsm/L', 'mcmol/L', 'Units',
            'cells/mcL', 'copies/mL', 'log copies/mL', 'index', 'ratio', 'M/mL', 'mcg/24 h', '#/mcL', 'ng/mL/h',
            'AU/mL', 'mL/min', 'inches', 'sqMETERS', '% of total Hb', 'unit' ]
a.sort!
puts a.join "', '"
