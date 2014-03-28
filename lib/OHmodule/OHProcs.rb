dir = File.dirname( __FILE__ )
require "#{dir}/OHMethods.rb"
require "#{dir}/OrgProportions.rb"

module OHProcs

  extend HL7
    
  IMP_PROC = Proc.new{ |val| val.include?( "IMPRESSION:" ) }
  ADT_PROC = Proc.new{ |val| val.include?( "ADDENDUM:" ) }
  OBS_TYPES = %w( TX NM SN TS )
  RAD_OBS_IDS = %w( &GDT &IMP &ADT )
   
  # -------------Define the Procs------------ #
  # MSH
  MSH10_P = Proc.new{ |rec| is_val?(rec,"msh10",'P') }
  MSH10_T = Proc.new{ |rec| is_val?(rec,"msh10",'T') }
  MSH11_23 = Proc.new{ |rec| is_val?(rec,"msh11",'2.3') }
  MSH11_24 = Proc.new{ |rec| is_val?(rec,"msh11",'2.4') }

  # PID  
  SEXES = define_group( "pid8", HL7::SEXES, :sex )
  PID10 = Proc.new{ |rec| has_val?(rec,"pid10") }
  PID12_AND_11_7 = Proc.new{ |rec| comp_has_val?(rec,"pid11",7) && has_val?(rec,"pid12") }
  PID15 = Proc.new{ |rec| has_val?(rec,"pid15") } 
  PID16 = Proc.new{ |rec| has_val?(rec,"pid16") }  
  PID17 = Proc.new{ |rec| has_val?(rec,"pid17") } 
  PID18_AND_PV119 = Proc.new{ |rec| both_have_vals?(rec,"pid18","pv119") }  
    
  # PV1
  PV17 = Proc.new{ |rec| has_val?(rec,"pv17") }
  PV18 = Proc.new{ |rec| has_val?(rec,"pv18") }
  PV19 = Proc.new{ |rec| has_val?(rec,"pv19") }
  PV117 = Proc.new{ |rec| has_val?(rec,"pv117") }  
  PV17_AND_PV18 = Proc.new{ |rec| both_have_vals?(rec,"pv17","pv18") }
  PV144 = Proc.new{ |rec| has_val?(rec,"pv144") }
  PV145 = Proc.new{ |rec| has_val?(rec,"pv145") }

  # ORC  
  ORC = Proc.new{ |rec| rec[:ORC] }  # if there is no ORC, then rec[:ORC] == nil
  ORC1 = Proc.new{ |rec| has_val?(rec,"orc1") }
  
  # OBR
  OBR7_AND_OBR22 = Proc.new{ |rec| both_have_vals?(rec,"obr7","obr22") }
  OBR_RES_STATS = define_group( "obr25", HL7::RESULT_STATUS, :obr_result_status ) 
  OBR27 = Proc.new{ |rec| has_val?(rec,"obr27") } 
  OBR31 = Proc.new{ |rec| has_val?(rec,"obr31") }
    
  # OBX  
  VAL_TYPES = define_group( "obx2", OBS_TYPES, :observation_type )
  OBX3 = Proc.new{ |rec| has_val?(rec,"obx3") }
  OBS_IDS = define_group( "obx3", RAD_OBS_IDS, :observation_ID )
  OBX5_IMP = Proc.new{ |rec| matches?(rec,"obx5",IMP_PROC) }
  OBX5_ADT = Proc.new{ |rec| matches?(rec,"obx5",ADT_PROC) }
  OBX5_SN = Proc.new{ |rec| is_type?( rec,"obx5",:SN ) }
  OBX5_NM = Proc.new{ |rec| is_type?( rec,"obx5",:NM ) }
  OBX5_TX = Proc.new{ |rec| is_type?( rec,"obx5",:TX ) }
  OBX5_TS = Proc.new{ |rec| is_type?( rec,"obx5",:TS ) }
  ABN_FLAGS = define_group( "obx11", HL7::ABNORMAL_FLAGS, :abnormal_flag )
  OBX_RES_STATS = define_group( "obr25", HL7::RESULT_STATUS, :obx_result_status ) 

  #-------------Group Procs for Quick Access-------------- #

  LAB = { value_is_structured_numeric: OBX5_SN, value_id_numeric: OBX5_NM, value_is_text: OBX5_TX,
          value_is_timestamp: OBX5_TS, attending_and_referring_shown: PV17_AND_PV18,
          has_order_control: ORC1 } + VAL_TYPES + OBX_RES_STATS + ABN_FLAGS
            
  RAD = { has_orc_segment: ORC, exam_end_shown: OBR27, study_reason_shown: OBR31,
          value_is_impression: OBX5_IMP, value_is_addendum: OBX5_ADT } + OBS_IDS 
  
  ADT = { language_shown:PID15, race_shown: PID10, religion_shown: PID17, marital_status_shown: PID16,
          country_code_shown_twice: PID12_AND_11_7, admit_date_shown: PV144,
          discharge_date_shown: PV145 } + SEXES
  
  ORDERS = { result_and_collection_date_shown: OBR7_AND_OBR22 } + OBR_RES_STATS
  
  CORE = { processing_ID_of_T: MSH10_T, processing_ID_of_P: MSH10_P, hl7_version_2_3: MSH11_23,
           hl7_version_2_4: MSH11_24, attending_doctor_shown: PV17, referring_doctor_shown: PV18,
           consulting_doctor_shown: PV19, admitting_doctor_shown: PV117, visit_ID_shown_twice: PID18_AND_PV119 }                 
  
  # fields to add with value lists pulled from current records
  # added at runtime by run_record_comparer
  ADT_FIELDS_TO_ADD = { hospital_service:"pv110", admit_source:"pv114", patient_type:"pv118",
                        financial_class:"pv120", discharge_disposition:"pv136", patient_class:"pv12" }   
  LAB_FIELDS_TO_ADD = { analyte:"obx4", procedure_ID:"obr4" }
  RAD_FIELDS_TO_ADD = { procedure_ID:"obr4" }
  
  public
  
  @lab = CORE + ORDERS + LAB
  @rad = CORE + ORDERS + RAD
  @adt = CORE + ADT
  class << self
    attr_reader :lab, :rad, :adt
  end
  
end