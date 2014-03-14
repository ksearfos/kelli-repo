for file in resources/rad_hl7/*
do
  FILE=$file rspec spec/hl7_specs/rad/rad_hl7_spec.rb
done
