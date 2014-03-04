# last updated 3/4/14
# last tested 3/4/14

module HL7
    
  # this class exists purely for easy handling of components
  class Field  
    attr_accessor :components, :original_text
    
    def initialize( field_text )
      @original_text = field_text
      @components = field_text.split( COMP_DELIM )    # an array of strings
    end 
    
    def to_s
      @original_text
    end
    
    def each
      @components.each{ |comp| yield(comp) }
    end
    
    def [](index)
      @components[index]
    end
    
    def size
      @components.size
    end
    
    def first_component
      @components.first
    end
    
    def method_missing( sym, *args, &block )
      if String.method_defined?( sym )      # fields should generally be treated as Strings
        @original_text.send( sym, *args )
      elsif Array.method_defined?( sym )    # might try to use array access methods, like first() or map()
        @components.send( sym, *args )
      else
        super
      end
    end
    
    # displays readable version of the components, headed by the index of the component
    #+  e.g. SMITH^JOHN^^JR.
    #+       1:SMITH, 2:, 3:JOHN, 4:JR.
    def view
      puts @original_text
      
      last = @components.size - 1
      for i in 0..last
        print "#{i}:#{@components[i]}"
        print i == last ? "\n" : ", "
      end
    end
    
    # HL7 puts date into the following format: YYYYMMDD
    # this will spit it back out as MM/DD/YYYY
    def as_date( delim = "/" )
      make_date( @original_text, delim )
    end

    # HL7 puts time into the following format: HHMM (24-hour clock)
    # could also be HHMMSS if seconds are included
    # this will spit it back out as HH:MM:SS AM/PM
    def as_time
      make_time( @original_text )
    end

    # HL7 puts time into the following format: YYYYMMDDHHNNSS (24-hour clock), seconds optional
    # this will spit it back out as MM/DD/YYYY HH:MM:SS AM/PM
    def as_datetime( delim = "/" )
      date = @original_text[0...8]
      time = @original_text[8..-1]
  
      make_date( date, delim ) + " " + make_time( time )
    end

    # HL7 puts names into the following format: Last^First^MI^Ext
    # this will spit it back out as First MI Last Ext
    # e.g. SMITH^JOHN^^JR. => JOHN SMITH JR.
    def as_name
      last = @components[0]
      first = @components[1]
      mi = @components[2]
      ext = @components[3]
  
      mi_str = ( mi && !mi.empty? ? "#{mi} " : "" )
      ext_str = ( ext && !ext.empty? ? " #{ext}" : "" )
  
      first + " " + mi_str + last + ext_str
    end

    private
      
    # MM/DD/YYYY
    def make_date( date, delim = "/" )
      yr = date[0...4]
      mon = date[4...6]
      day = date[6...8]
  
      mon + delim + day + delim + yr
    end

    # HH:MM:SS AM/PM
    def make_time( time )
      hr = time[0...2]
      min = time[2...4]
      sec = time[4...6]
      ampm = "AM"
    
      if ( hr.to_i > 12 )
        ampm = "PM"
        hr = hr.to_i - 12
      end
  
      str = hr + ":" + min
      str << ":" + sec if sec
      str << " " + ampm
    end
  end
 
end