check_type :lab
check_all "core"
check_all "orders"
check
  :processing_id,
  :order_control_id,
  :specimen_source,
  :observation_component_id,
  :obeservation_value_type,
  :observation_result_status,
  :units,
  :reference_range,
  :abnormal_flag
end