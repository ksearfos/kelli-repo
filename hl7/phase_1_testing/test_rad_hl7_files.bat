for /f %%f in ('dir /s/b resources\rad_hl7\*') do (
set FILE=%%f 
rspec spec\hl7_specs\rad\rad_hl7_spec.rb
)