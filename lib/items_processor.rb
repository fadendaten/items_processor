require "items_processor/version"

module ItemsProcessor
  
  class Merge
    def initialize(receipts)
      @receipts = receipts
    end
    
    def evaluate
      init = {}
      @receipts.uniq.each do |r|
        merge_items init, r.line_items_to_hash
      end
      init
    end
    
    private
      def merge_items(init, items)
        items.each do |a_id, hash|
          if init[a_id]
            init[a_id][:quantity] += hash[:quantity]
          else
            init[a_id] = { :quantity => hash[:quantity] }
          end
        end
        init
      end
  end
  
  class Sub
    def initialize(minuend, subtrahend, options={})
      if options[:inversed]
        @inv = true
        @min = subtrahend
        @sub = minuend
      else
        @min = minuend
        @sub = subtrahend
      end
      @tol = options[:tolerance]
    end
    
    def evaluate
      diff = @min.clone
      @sub.each do |a_id, hash|
        if diff[a_id]
          diff[a_id][:quantity] -= hash[:quantity]
          diff[a_id][:price_value] -= hash[:price_value] if @min[a_id][:price_value]
        else
          diff[a_id] = { :quantity       => hash[:quantity] * -1,
                         :price_value    => hash[:price_value],
                         :price_currency => hash[:price_curreny] }
        end
        if @tol
          init_q = @inv ? hash[:quantity] : @min[a_id][:quantity]
          p_diff = percental_diff(init_q, diff[a_id][:quantity])
          diff[a_id][:p_diff] = "#{p_diff}%"
          diff[a_id][:tolerated] = tolerated?(p_diff)
        end
      end
      diff
    end
    
    private
      def percental_diff(q, diff)
        q = q.to_f
        diff = diff.abs.to_f
        (100/q*diff).round 1
      end
    
      def tolerated?(diff)
        diff < @tol
      end
  end
  
  # ==== Terminals ====
  
  def self.merge(receipts)
    Merge.new(receipts).evaluate
  end
  
  def self.sub(minuend, subtrahend, options={})
    Sub.new(minuend, subtrahend, options).evaluate
  end
end
