for /f %%f in ('dir /s/b resources\lab_hl7\*') do (
set FILE=%%f 
rspec spec\hl7_specs\lab\lab_hl7_spec.rb
)