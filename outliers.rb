module MCollective
  class Aggregate
    class Outliers<Base

      def startup_hook
        result[:value] = {}
        result[:type] = :collection
        @aggregate_format = "%s : %s" unless @aggregate_format

        @data_set = []
        @quartiles = {:high => nil,
                      :low=> nil}
        @outliers = {:top => [], :bottom => []}
      end

      def process_result(value, reply)
        @data_set << value
      end

      def summarize
        @data_set.sort!
        set_quartiles
        find_outliers
        super
      end

      # Determine quartiles of dataset
      def set_quartiles
        n = @data_set.size
        l = Float((1.0/4.0)*(n + 1))
        u = Float((3.0/4.0)*(n + 1))

        l_rem = (l - Integer(l)).abs
        q1 = (((1-l_rem) * (@data_set[l.truncate - 1])) + (l_rem * @data_set[l.truncate]))

        u_rem = (u - Integer(u)).abs
        q3 = (((1-u_rem) * (@data_set[u.truncate] - 1)) + (u_rem * @data_set[u.truncate]))

        iqr = (q3 - q1).abs

        @quartiles[:low] = q1 - (1.5 * iqr)
        @quartiles[:high] = q3 + (1.5 * iqr)

      end

      def find_outliers
        @data_set.each do |data_item|
          @outliers[:top] << data_item if (data_item > @quartiles[:high])
          @outliers[:bottom] << data_item if (data_item < @quartiles[:low])
        end

        0..(@arguments.first).times do |index|
          [:top, :bottom].each do |pos|
            @outliers[pos].sort!{|a,b| b <=> a}
            result[:value]["#{pos.to_s.capitalize} Outlier : #{index + 1} of #{@arguments}"] = @outliers[pos][index] if @outliers[pos][index]
          end
        end
      end
    end
  end
end
