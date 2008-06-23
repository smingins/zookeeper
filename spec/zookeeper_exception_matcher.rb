module ZooKeeperExceptionhMaker
  
  class RaiseZooKeeperException
    
      def initialize(error_or_message=Exception, code=nil)
        if String === error_or_message
          @expected_error = Exception
          @expected_message = error_or_message
        else
          @expected_error = error_or_message
          @expected_code = code
        end
      end
      
      def matches?(proc)
        @raised_expected_error = false
        @raised_other = false
        begin
          proc.call
        rescue @expected_error => @actual_error
          if @expected_code.nil?
            @raised_expected_error = true
          else
            verify_code
          end
        rescue Exception => @actual_error
          @raised_other = true
        ensure
          return @raised_expected_error
        end
      end

      def verify_code
        case @expected_code
        when Regexp
          if @expected_code =~ @actual_error.code
            @raised_expected_error = true
          else
            @raised_other = true
          end
        else
          if @expected_code == @actual_error.code
            @raised_expected_error = true
          else
            @raised_other = true
          end
        end
      end
      
      def failure_message
        return "expected #{expected_error}#{actual_error}" if @raised_other || !@raised_expected_error
      end

      def negative_failure_message
        "expected no #{expected_error}#{actual_error}"
      end
      
      def description
        "raise #{expected_error}"
      end
      
      private
        def expected_error
          case @expected_code
          when nil
            @expected_error
          when Regexp
            "#{@expected_error} with code matching #{@expected_code.inspect}"
          else
            "#{@expected_error} with #{@expected_code.inspect}"
          end
        end

        def actual_error
          @actual_error.nil? ? " but nothing was raised" : ", got #{@actual_error.inspect} with #{@actual_error.code}"
        end
    end
    
  def raise_zookeeper_exception(code)
     RaiseZooKeeperException.new(ZooKeeper::KeeperException, code)
  end
end