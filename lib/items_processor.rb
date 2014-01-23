# Copyright (c) 2014 fadendaten gmbh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "items_processor/version"

module ItemsProcessor

  class Merge
    attr_reader :receipts

    def initialize(receipts)
      @receipts = receipts
    end

    def evaluate
      init = {}
      receipts.each do |r|
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
    attr_reader :inv, :min, :sub, :tol

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
      diff = min.clone
      sub.each do |a_id, hash|
        if diff[a_id]
          diff[a_id][:quantity] -= hash[:quantity]
          diff[a_id][:price_value] -= hash[:price_value] if min[a_id][:price_value]
        else
          diff[a_id] = { :quantity       => hash[:quantity] * -1,
                         :price_value    => hash[:price_value],
                         :price_currency => hash[:price_curreny] }
        end
        if tol
          init_q = inv ? hash[:quantity] : min[a_id][:quantity]
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
      diff < tol
    end
  end

  Kernel.module_eval do
    def ip_merge(receipts)
      Merge.new(receipts).evaluate
    end
    def ip_sub(minuend, subtrahend, options={})
      Sub.new(minuend, subtrahend, options).evaluate
    end
  end
end
