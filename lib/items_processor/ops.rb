module ItemsProcessor
  class ::Hash
    def line_items_to_hash
      self
    end
  end

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
      @min = minuend.line_items_to_hash
      @sub = subtrahend.line_items_to_hash
      @tol = options[:tolerance]
    end

    def evaluate
      diff = {}
      articles_ids = min.keys | sub.keys

      articles_ids.each do |a_id|
        min_quantity = min.fetch(a_id, { :quantity => 0 })[:quantity]
        sub_quantity = sub.fetch(a_id, { :quantity => 0 })[:quantity]

        diff[a_id] = { :quantity => min_quantity - sub_quantity }
        diff[a_id][:quantity] *= -1 if inv

        if price_info_exists?(min[a_id], sub[a_id])
          min_price = min.fetch(a_id, { :price_value => 0.0 })[:price_value]
          sub_price = sub.fetch(a_id, { :price_value => 0.0 })[:price_value]
          if min_price && sub_price
            diff[a_id][:price_value] = min_price - sub_price
            diff[a_id][:price_value] *= -1 if inv
          end
        end

        if tol
          p_diff = percental_diff(min_quantity, diff[a_id][:quantity])
          diff[a_id][:p_diff] = p_diff
          diff[a_id][:tolerated] = tolerated?(p_diff)
        end
      end

      diff
    end

    private

    def price_info_exists?(h1, h2)
      (h1 && h1[:price_value]) || (h2 && h2[:price_value])
    end

    def percental_diff(q, diff)
      q    = 1 if q.zero?
      q    = q.to_f
      diff = diff.abs.to_f
      (100 / q * diff).round 1
    end

    def tolerated?(diff)
      diff < tol
    end
  end
end
