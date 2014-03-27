require 'ruby-hl7'

class HL7::Message
  
  # overwrites default @segments_by_name variable to work in a more intuitive way :)
  # when this method is run, gives @segments_by_name the values of { name => array of all segment objects }
  # e.g. { :PID => [PID object 1, PID object 2] }
  # essentially this allows you to access field values by name, e.g. message[:PID][0].patient_name
  def create_children
    hash = {}
    @segments_by_name.each{ |k,v|
      str = v.to_s
      str_ary = v.to_s.split( ", #{k}" )    # split into individual entries
      str_ary.map!{ |seg| "#{k}|#{seg}" }   # each entry lost its label initially, so put it back
      
      ch_seg_cl = Object.const_get( "HL7::Message::Segment::#{k}" )    # find segment child class equal with
                                                                       # with same name as the key, e.g. PID
      seg_ary = []
      str_ary.each{ |s|
        seg_ary << ch_seg_cl.new( s )     # an array of objects of type HL7::Message::Segment::[segment name]
      }
      
      hash[k] = seg_ary
    }
    
    @segments_by_name = hash              # overwrite default @segments_by_name so we can still use [] notation
  end
  
  # there is not actually a way to view @segments_by_name, so I have added this
  # prints something similar to:
  #      PID: PID|||12345||Name^Name^^^MI||||other stuff, PID|||1246||Name^Name^^^MI|||||
  #      ORC: ORC|RE, ORC|RE
  #      ...
  def view_children
    puts @segments_by_name.each{ |k,v| puts k.to_s + ": " + v.to_s }
  end
  
end