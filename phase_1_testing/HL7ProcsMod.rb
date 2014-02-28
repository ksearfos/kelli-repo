# last updated 2/28/14 3:34pm

require './extended_base_classes.rb'

module HL7Procs

  SN_PROC = Proc.new{ |val| val =~ />\d+|<\d+/ }   # proc vs lambda makes no difference here
  NM_PROC = Proc.new{ |val| val.is_numeric? }      #+ so I chose to break things up a bit
  TX_PROC = Proc.new{ |val| !val.empty? && !SN_PROC.call(val) && !NM_PROC.call(val) }   # there is something there, and it
  IMP_PROC = Proc.new{ |val| val.include?( "IMPRESSION:" ) }                            #+ isn't NM or SN format
  ADT_PROC = Proc.new{ |val| val.include?( "ADDENDUM:" ) }
  DOC_SZ_PROC = Proc.new{ |val| val.size > 2 }
  AUTO_FAIL = Proc.new{ |*| return false }     # this one may or may not be given an arg, so must be a proc
  
  # -------------Define the Procs------------ #
  # MSH
  EVENT = Proc.new{ |rec| has_val?(rec,"msh9") }
  P_ID = Proc.new{ |rec| is_val?(rec,"msh10","P") }
  T_ID = Proc.new{ |rec| is_val?(rec,"msh10","T") }
  ID_23 = Proc.new{ |rec| is_val?(rec,"msh11","2.3") }
  ID_24 = Proc.new{ |rec| is_val?(rec,"msh11","2.4") }
  
  # PV1
  PT_CL_E = Proc.new{ |rec| is_val?(rec,"pv12","E") }
  PT_CL = Proc.new{ |rec| has_val?(rec,"pvi1") }
  PT_LOC_ED = Proc.new{ |rec| is_val?(rec,"pv13","ED") }
  PT_LOC = Proc.new{ |rec| has_val?(rec,"pv13") }
  EMPTY_32 = Proc.new{ |rec| !seg_has_val?(rec,"pv13",2) }  
  EMPTY_33 = Proc.new{ |rec| !seg_has_val?(rec,"pv13",3) }  
  ATT = Proc.new{ |rec| has_val?(rec,"pv17") }
  REF = Proc.new{ |rec| has_val?(rec,"pv18") }
  CNS = Proc.new{ |rec| has_val?(rec,"pv19") }
  ADM = Proc.new{ |rec| has_val?(rec,"pv117") }
  ATT_SZ = Proc.new{ |rec| matches?(rec,"pv17",DOC_SZ_PROC) }
  REF_SZ = Proc.new{ |rec| matches?(rec,"pv18",DOC_SZ_PROC) }
  CNS_SZ = Proc.new{ |rec| matches?(rec,"pv19",DOC_SZ_PROC) }
  ADM_SZ = Proc.new{ |rec| matches?(rec,"pv117",DOC_SZ_PROC) }
  ATT_EQ_REF = Proc.new{ |rec| fields_are_same?(rec,"pv17","pv18") }
  HOSP_SV = Proc.new{ |rec| has_val?(rec,"pv110") }
  ADM_SC = Proc.new{ |rec| has_val?(rec,"pv114") }
  PT_TYPE = Proc.new{ |rec| has_val?(rec,"pv118") }
  FIN_CL = Proc.new{ |rec| has_val?(rec,"pv120") }
  DCH_DISP = Proc.new{ |rec| has_val?(rec,"pv136") }
  ADM_DT = Proc.new{ |rec| has_val?(rec,"pv144") }
  DCH_DT = Proc.new{ |rec| has_val?(rec,"pv145") }
  
  # OBX
  TX_TYPE = Proc.new{ |rec| is_val?(rec,"obx2","TX") }
  NM_TYPE = Proc.new{ |rec| is_val?(rec,"obx2","NM") }
  SN_TYPE = Proc.new{ |rec| is_val?(rec,"obx2","SN") }
  OBS_ID = Proc.new{ |rec| has_val?(rec,"obx3") }
  GDT_ID = Proc.new{ |rec| is_val?(rec,"obx3","&GDT") }
  IMP_ID = Proc.new{ |rec| is_val?(rec,"obx3","&IMP") }
  ADT_ID = Proc.new{ |rec| is_val?(rec,"obx3","&ADT") }
  IMP_VAL = Proc.new{ |rec| matches?(rec,"obx5",IMP_PROC) }
  ADT_VAL = Proc.new{ |rec| matches?(rec,"obx5",ADT_PROC) }
  SN_VAL = Proc.new{ |rec| matches?(rec,"obx5",SN_PROC) }
  NM_VAL = Proc.new{ |rec| matches?(rec,"obx5",NM_PROC) }
  TX_VAL = Proc.new{ |rec| matches?(rec,"obx5",TX_PROC) }
  UNITS = Proc.new{ |rec| has_val?(rec,"obx6") }
  REF_RG = Proc.new{ |rec| has_val?(rec,"obx7") }
  FLAG_H = Proc.new{ |rec| is_val?(rec,"obx8","H") }  
  FLAG_I = Proc.new{ |rec| is_val?(rec,"obx8","I") }
  FLAG_CH = Proc.new{ |rec| is_val?(rec,"obx8","CH") }
  FLAG_CL = Proc.new{ |rec| is_val?(rec,"obx8","CL") }
  FLAG_L = Proc.new{ |rec| is_val?(rec,"obx8","L") }
  FLAG_A = Proc.new{ |rec| is_val?(rec,"obx8","A") }
  FLAG_U = Proc.new{ |rec| is_val?(rec,"obx8","U") }
  FLAG_N = Proc.new{ |rec| is_val?(rec,"obx8","N") }
  FLAG_C = Proc.new{ |rec| is_val?(rec,"obx8","C") } 
  
  # PID
  PT_ID = Proc.new{ |rec| has_val?(rec,"pid3") } 
  NAME = Proc.new{ |rec| has_val?(rec,"pid5") }
  DOB = Proc.new{ |rec| has_val?(rec,"pid7") }
  SEX_M = Proc.new{ |rec| is_val?(rec,"pid8","M") }  
  SEX_F = Proc.new{ |rec| is_val?(rec,"pid8","F") }
  SEX_O = Proc.new{ |rec| is_val?(rec,"pid8","O") }  
  RACE = Proc.new{ |rec| has_val?(rec,"pid10") }
  ADDR = Proc.new{ |rec| has_val?(rec,"pid11") }  
  ADDR_7 = Proc.new{ |rec| seg_has_val?(rec,"pid11",7) }  
  CTY_CD = Proc.new{ |rec| has_val?(rec,"pid12") } 
  LANG = Proc.new{ |rec| has_val?(rec,"pid15") }
  MAR_ST = Proc.new{ |rec| has_val?(rec,"pid16") }  
  REL = Proc.new{ |rec| has_val?(rec,"pid17") } 
  VISIT_ID = Proc.new{ |rec| has_val?(rec,"pid18") || has_val?(rec,"pv119") }  
  SSN = Proc.new{ |rec| has_val?(rec,"pid19") }
   
  # ORC
  ORC_EXISTS = Proc.new{ |rec| !rec[:ORC].nil? }
  ORD_ID = Proc.new{ |rec| has_val?(rec,"orc1") }
  TRANS_DT = Proc.new{ |rec| has_val?(rec,"orc9" ) }
  
  # OBR
  REP_ID_1 = Proc.new{ |rec| is_val?(rec,"obr1",1) } 
  ORD_NUM = Proc.new{ |rec| has_val?(rec,"obr3") }  
  SER_ID = Proc.new{ |rec| has_val?(rec,"obr4") } 
  ORD_DT = Proc.new{ |rec| has_val?(rec,"obr7") } 
  ORD_MD = Proc.new{ |rec| has_val?(rec,"obr16") }
  RES_DT = Proc.new{ |rec| has_val?(rec,"obr22") }
  RES_ST = Proc.new{ |rec| has_val?(rec,"obr25") } 
  RES_ST_F = Proc.new{ |rec| is_val?(rec,"obr25","F") }
  RES_ST_I = Proc.new{ |rec| is_val?(rec,"obr25","I") }
  RES_ST_C = Proc.new{ |rec| has_val?(rec,"obr25","C") }
  RES_ST_P = Proc.new{ |rec| has_val?(rec,"obr25","P") }
  EXAM_DT = Proc.new{ |rec| has_val?(rec,"obr27") } 
  REASON = Proc.new{ |rec| has_val?(rec,"obr31") }
  RES_INT = Proc.new{ |rec| has_val?(rec,"obr32") }
  
  # OTHER
  EVN = Proc.new{ |rec| has_seg?(rec,"evn") }
  
  #-------------Group Procs for Quick Access-------------- #
  # LAB OUTPUT CRITERIA
  LAB_CRITERIA = [ EVENT, T_ID, ID_23, P_ID, ID_24, ATT, REF, TX_TYPE, SN_TYPE, NM_TYPE, OBS_ID, TX_VAL,
                   NM_VAL, SN_VAL, UNITS, REF_RG, FLAG_H, FLAG_I, FLAG_CH, FLAG_CL, FLAG_L, FLAG_A, FLAG_U,
                   FLAG_N, FLAG_C, PT_ID, NAME, DOB, SEX_M, SEX_F, SEX_O, VISIT_ID, SSN, ORD_NUM, SER_ID,
                   ORD_DT, ORD_MD, RES_ST_F, RES_ST_I, RES_ST_C, RES_ST_P, ATT_EQ_REF ] 
  
  # RAD OUTPUT CRITERIA
  RAD_CRITERIA = [ EVENT, SER_ID, T_ID, ID_23, TX_TYPE, SN_TYPE, NM_TYPE, TX_VAL, NM_VAL, SN_VAL, RES_DT, 
                   PT_ID, NAME, DOB, SEX_M, SEX_F, SEX_O, VISIT_ID, SSN, ORD_NUM, ORD_DT, ORD_MD, RES_ST, 
                   REASON, RACE, REP_ID_1, PT_CL_E, PT_LOC_ED, EMPTY_32, EMPTY_33, CTY_CD, ADDR_7, LANG,
                   MAR_ST, GDT_ID, IMP_ID, ADT_ID, IMP_VAL, ADT_VAL, TRANS_DT, RES_INT, EXAM_DT ] 
                     
  # ENCOUNTER OUTPUT CRITERIA
  ENC_CRITERIA = [ EVENT, PT_ID, VISIT_ID, PT_LOC, ADM_DT, NAME, DOB, SEX_M, SEX_F, SEX_O, SSN, PT_CL, ATT, DCH_DT,
                   P_ID, T_ID, ID_23, ID_24, RACE, CTY_CD, ADDR_7, LANG, MAR_ST, REL, CNS, ADM, ATT_SZ, REF_SZ,
                   ADM_SZ, CNS_SZ, ATT_EQ_REF, HOSP_SV, ADM_SC, PT_TYPE, FIN_CL, DCH_DISP, EVN ]
  
  # ----------------Actual Methods---------------- #
  # It is ironic that in a module full of procs, we also have methods
  # but I chose to break some more generic pieces of code into methods
  # for readability
  
  def HL7Procs.has_seg?( record, segment )
    seg = segment.upcase.to_sym
    !record[seg].nil?
  end
  
  # does the given field of the record have a value?
  # returns true if at least one matching field has a value, false otherwise
  def HL7Procs.has_val?( record, field )
    res = record.fetch_field( field )   # could be multiple occurrences of the segment -> multiple values returned
    res.has_value?
  end
  
  # is the value of the given field in the record the value we desire?
  # returns true if at least one field matches the given value, false otherwise
  def HL7Procs.is_val?( record, field, value )
    res = record.fetch_field( field )   # could be multiple occurrences of the segment -> multiple values returned
    res.map!{ |r| r = r.chomp( "]" ) }
    res.include?( value.to_s )
  end

  # is_val? for proc
  # does the value of the given field in the record make the given code return true?
  # returns true if at least one field passes, false otherwise
  def HL7Procs.matches?( record, field, code )
    res = record.fetch_field( field )   # could be multiple occurrences of the segment -> multiple values returned
    res.each{ |r|
      next if r.nil?
      return true if code.call(r)
    }   
    return false  # if regex doesn't match
  end
  
  # checks if the values of two fields are the same - by default only checks cases where both fields have
  #+  non-empty values
  # optionally force checking of empty values - if you want f1 = "abc" and f2 = "" to count as not the same,
  #+  set check_empty to true
  def HL7Procs.fields_are_same?( record, f1, f2, check_empty = false )
    res1 = record.fetch_field( f1 )
    res2 = record.fetch_field( f2 )
    return false if res1.size != res2.size    # if there isn't a 1:1 mapping, they clearly aren't the same!
    
    for i in (0...res1.size)
      val1 = res1[i]
      val2 = res2[i]
      
      next if ( !check_empty && ( val1.empty? || val2.empty? ) )    # empty values automatically pass if check_empty = false
      return false if ( val1.to_s != val2.to_s )       # I am assuming we want "1" and 1 to be considered the same
    end
    
    # if we get here, there were no non-empty fields that didn't contain the same text, so...
    return true
  end
  
  def HL7Procs.seg_has_val?( record, field, comp )
    fs = record.fetch_field( field )
    fs.each{ |f|
      c = components( f )[comp-1]
      next if c.nil?
      return true if !c.empty?   # component indices start at 1 in the message, so comp8 has index 7
    }
    return false       # no match in any of the fields
  end
  
  # at least one field in the record has a segment of given index (idx) that matches the desired value
  def HL7Procs.seg_is_val?( record, field, comp, val )
    fs = record.fetch_field( field )
    fs.each{ |f|
      comps = components( f )
      return true if ( comps[comp-1] == val )    # component indices start at 1 in the message, so comp8 has index 7
    }
    return false       # no match in any of the fields
  end
  
  # ---------Methods that Might be Useful Later but That I Decided Not to Use Now--------- #

  # is this a MGH record?
  def is_mgh?(record)
    mc_id = record[:MSH][0].e10
    pr_id = record[:MSH][0].e11
    mc_id == 'P' && pr_id == 2.3
  end
  
  # is this a STAR (or Hardin) record?
  def is_star?(record)
    mc_id = record[:MSH][0].e10
    pr_id = record[:MSH][0].e11
    mc_id == 'T' && pr_id == 2.4
  end
  
  # does the attending doctor match the referring doctor?
  def att_matches_ref?(record)
    att = record.fetch_field( "pv17" )
    ref = record.fetch_field( "pv18" )
    
    match = false
    ref.each{ |val| 
      next if val.empty?
      
      i = ref.index(val)
      match = ( att[i] == val )    # referring and attending match
      break if match
    }
    
    match
  end
  
  # is the observation value actually of the type the segment says it is?
  def obs_value_type_verify(rec,type)
    type = type.to_s.upcase
    return false if type != ( 'SN' || 'TX' || 'NM' )
    
    match = false
    types = record.fetch_field( "obx2" )
    types.each{ |t|
      next unless t == type
      
      i = types.index( t )
      val = record[:OBX][i].e5
      
      if type == 'SN'
        match = ( val =~ /[>\d+|<\d+]/ )     # > or < some number
      elsif type == 'NM'
        match = ( )
      else
        match = true       # 'TX' is text, and can hold anything
      end
    }
    
    match
  end
end