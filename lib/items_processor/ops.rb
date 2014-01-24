module ItemsProcessor
  class Merge
    attr_reader :receipts, :merged

    def initialize(receipts)
      @receipts = receipts
    end

    def evaluate
      @merged = {}
      receipts.each do |r|
        merge_items r.line_items_to_hash
      end
      merged
    end

    private

    def merge_items(items)
      items.each do |a_id, hash|
        if merged[a_id]
          merged[a_id][:quantity] += hash[:quantity]
        else
          merged[a_id] = { :quantity => hash[:quantity] }
        end
      end
    end
  end

  class Sub
    attr_reader :inv, :min, :sub, :tol

    def initialize(minuend, subtrahend, options = {})
      @inv = options.fetch(:inversed, false)
      @min = minuend
      @sub = subtrahend
      @tol = options[:tolerance]
    end

    def evaluate
      diff = {}
      sub.each do |a_id, hash|
        if min[a_id]
          diff[a_id] = { :quantity => min[a_id][:quantity] - hash[:quantity] }
          if hash[:price_value]
            diff[a_id][:price_value] = if min[a_id][:price_value]
              min[a_id][:price_value] - hash[:price_value]
            else
              hash[:price_value] * -1
            end
          end
        else
          diff[a_id] = { :quantity => hash[:quantity] * -1 }
          if hash[:price_value]
            diff[a_id][:price_value] = hash[:price_value] * -1
          end
        end
        if tol
          init_q = min.fetch(a_id, { :quantity => 1 })[:quantity]
          p_diff = percental_diff(init_q, diff[a_id][:quantity])
          diff[a_id][:p_diff] = p_diff
          diff[a_id][:tolerated] = tolerated?(p_diff)
        end
        if inv
          diff[a_id][:quantity] *= -1
          diff[a_id][:price_value] *= -1 if diff[a_id][:price_value]
        end
      end
      diff
    end

    private

    def percental_diff(q, diff)
      q    = q.to_f
      diff = diff.abs.to_f
      (100/q*diff).round 1
    end

    def tolerated?(diff)
      diff < tol
    end
  end
end
