module MCollective
  class Aggregate
    class Deviant<Base

      def startup_hook
        result[:value] = {}
        result[:type] = :collection
        @aggregate_format = "%s : %s" unless @aggregate_format

        @data_set = []
      end

      def process_result(value, reply)
        @data_set << [reply[:sender], value]
      end

      def summarize
        high = []
        low = []
        top = 0
        bottom = 0

        @data_set.sort!{|a,b| a[1] <=> b[1]}

        @arguments[0] = @data_set.size if( @data_set.size < @arguments[0] / 2)

        if @arguments[0] % 2 == 0
          top = @arguments[0] / 2
          bottom = @arguments[0] / 2
        else
          top = @arguments[0] / 2 + 1
          bottom = @arguments[0] - top
        end

        low = @data_set[0..(bottom-1)]
        high = @data_set[(@data_set.size - top)..(@data_set.size - 1)]

        result[:value]['Deviants(High)'] = high
        result[:value]['Deviants(Low)'] = low
        super
      end
    end
  end
end
