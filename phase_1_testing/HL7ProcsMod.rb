module HL7Procs
  HAS_VAL = Proc.new{ |rec,field| 
    res = rec.fetch_field( field )   # array of values, some of which might be ""
    res.has_value?
  }
  MSH9 = Proc.new{ |rec| HL7Procs::HAS_VAL.call(rec,"msh9") }
  ALLFALSE = Proc.new{ |rec| false }
  OBX3 = Proc.new{ |rec| HL7Procs::HAS_VAL.call(rec,"obx3") }
  PID1 = Proc.new{ |rec| HL7Procs::HAS_VAL.call(rec,"pid1") } 
end