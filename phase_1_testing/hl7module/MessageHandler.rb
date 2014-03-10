#------------------------------------------
#
# MODULE: HL7
#
# CLASS: HL7::MessageHandler
#
# DESC: Defines an object to read HL7 message from a file and split it into Message objects. Basically sets the stage
#         for treating the file text as a HL7 message.
#       Performs minor reformatting to insure there are no blank lines, and all line breaks are done with \n and not \r
#       The message handler class takes a filepath where HL7 data is stored, reads from it, and standardizes the format of
#         the text. It then breaks the text into individual records and initiales Message objects from those. It will also
#         keep track of each of those Messages and the value separators used by the message. Lastly, it will create new
#         Segment child classes for each type of segment that appears in the message (which are used when initializing
#         Messages).
#       It is assumed that the file is in a valid text format and uses either the Windows-style line endings (\r and \r\n)
#         or the Unix style (\n). It also assumes the file is UTF-8 encoded.
#
# EXAMPLE: MessageHandler => "MSH|...MSH|...MSH|..." / [ Message1, Message2, Message 3 ]
#
# CLASS VARIABLES: none; uses HL7::SEG_DELIM and modifies HL7.separators
#
# READ-ONLY INSTANCE VARIABLES:
#    @message [String]: stores entire message text
#    @records [Array]: stores individual records as Message objects
#    @segment_types [Array]: stores list of the types of segments found in the message
#
# CLASS METHODS: none
#
# INSTANCE METHODS:
#    new(file,limit): creates new MessageHandler object and reads in text from file, up to limit records (if specified)
#    to_s: returns String form of MessageHandler, which is the text of the file
#    [](index): returns Message at given index
#    each(&block): loops through each record, executing given code
#    method_missing: tries to call method on @records (Array)
#                    then tries to call method on @message (String)
#                    then gives up and throws exception
#
# CREATED BY: Kelli Searfos
#
# LAST UPDATED: 3/10/14 11:09 AM
#
# LAST TESTED: 3/4/14
#
#------------------------------------------

module HL7Test
  
  class MessageHandler
    @@lim_default = 0       # makes it easier to update this way
    
    attr_reader :message, :records, :segment_types
    
    def initialize( file, limit = @@lim_default )
      @message = ""
      @records = []
      @segment_types = [:MSH]
      
      read_message( file, limit )    # updates @message, @segment_types
      get_separators                 # updates @separators
      break_into_records             # updates @records
    end
    
    def to_s
      @message
    end
    
    def []( index )
      @records[index]
    end
    
    def each
      @records.each{ |rec| yield(rec) }
    end
    
    def method_missing( sym, *args, &block )
      if Array.method_defined?( sym )
        @records.send( sym, *args )
      elsif String.method_defined?( sym )
        @message.send( sym, *args )
      else
        super
      end
    end
    
    private
    
    # reads in a HL7 message as a text file from the given filepath and stores it in @message
    # changes coding to end in \n for easier parsing
    def read_message( file, limit = @@lim_default )
      valid_limit = ( limit > 0 && limit != @@lim_default )   # is there a real limit specified?
      chars = ""                                              #+  user could say limit = -1 but that isn't helpful
      do_break = false
      
      puts "Reading #{file}..."
      File.open( file, "r" ).each_char do |ch|
        if ch == "\r" then chars << "\n"     # convert to useful character
        else chars << ch
        end

        do_break = valid_limit && chars.scan(/MSH/).size > limit    # if we have a limit, and we have reached it,
        break if do_break                                           #+ stop reading file
      end
      
      chars.squeeze!( "\n" )                # only need one line break at a time
      ary = chars.split( "\n" )
      ary.pop if do_break                   # remove last line ONLY IF it's the header of an unwanted record
      ary.delete_if{ |line| line !~ /\S/}   # remove any lines that are empty
      #############doesn't work as written, need to reference HL7.separators[:field] but not defined yet
      ary.each{ |line|
        type = line.split(FIELD_DELIM).first     # first field of each line, i.e. the segment type
        @segment_types << type.upcase.to_sym unless type.include?( "MSH" )
      }
      
      @segment_types.uniq!                  # a list of all segment types included in this message       
      @message = ary.join( SEG_DELIM )      # now glue the pieces back together, ready to be read as HL7 segments
    end

    def get_separators
      eol = @message.index( SEG_DELIM )
      line = @message[0...eol]         # looks something like: MSH|^~\&|info|info|info
      
      i = line.index( "MSH" )          # index marking the beginning of the first occurrence of 'MSH'
      i += 3                           # i was index of the M in MSH; need index of first character after H
      HL7.separators[:field] = line[i]
      HL7.separators[:comp] = line[i+1]
      HL7.separators[:subcomp] = line[i+2]
      HL7.separators[:subsub] = line[i+3]
      HL7.separators[:sub_subsub] = line[i+4]  
    end
        
    # sets @records to contain all HL7 messages contained within @message, as HL7::Message objects
    # can access segments as @records[index][segment_name]
    # e.g. hl7_messages_array[2][:PID] will return the PID segment of the 3rd record
    def break_into_records
      @segment_types.each{ |type|
        HL7Test.new_typed_segment( type )
      }
      
      all_recs = records_by_text
      @records = all_recs.map{ |msg| Message.new( msg ) }
    end
        
    # returns array of strings containing hl7 message of individual records, based on @message
    def records_by_text
      hdrs = @message.scan( HDR )      # all headers (will be needed later)
      recs = @message.split( HDR )     # split across headers, yielding individual records
      
      all_recs = []
      for i in 0...hdrs.size
        all_recs << hdrs[i] + recs[i].chomp      # those pesky endline characters cause a LOT of problems!
      end

      all_recs
    end

  end

end