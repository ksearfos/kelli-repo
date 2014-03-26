# last updated 3/4/14
# last tested 3/4/14

module HL7
  
  class MessageHandler
  
    attr_reader :message, :records
    
    def initialize( file )
      @message = ""
      @records = []
      
      read_message( file )     # updates @message
      break_into_records       # updates @records
    end
    
    def []( index )
      @records[index]
    end
    
    def each
      @records.each{ |rec| yield(rec) }
    end

    def size
      @records.size
    end
    
    private
    
    # reads in a HL7 message as a text file from the given filepath and stores it in @message
    # changes coding to end in \n for easier parsing
    def read_message( file )
      puts "Reading #{file}..."
      lines = File.open( file ) { |f| f.readlines }

      lines.delete_if{ |l| l !~ /\S/ }    # all whitespace, so get rid of this line
      lines.each{ |l| l.chomp! }          # get rid of all end-of-line characters, including CR, CRLF, and LF
      @message = lines.join( "\n" )       # now paste them back together with the end-of-line character we want
    end  
    
    # sets @records to contain all HL7 messages contained within @message, as HL7::Message objects
    # can access segments as @records[index][segment_name]
    # e.g. hl7_messages_array[2][:PID] will return the PID segment of the 3rd record
    def break_into_records
      all_recs = records_by_text
      @records = all_recs.map{ |msg| HL7::Message.new( msg ) }
    end
        
    # returns array of strings containing hl7 message of individual records, based on @message
    def records_by_text
      hdrs = @message.scan( HDR )      # all headers (will be needed later)
      recs = @message.split( HDR )     # split across headers, yielding individual records
      recs.delete_if{ |r| r.empty? }
      
      all_recs = []
      for i in 0...hdrs.size
        all_recs << hdrs[i] + recs[i].chomp      # those pesky endline characters cause a LOT of problems!
      end

      all_recs
    end
    
  end

end
