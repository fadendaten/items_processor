require "items_processor/ops"

module ItemsProcessor
  # Provides the methods #ip_merge and #ip_sub. This module will get mixed into
  # Object in order to have access to those methods globally.
  module ObjectExt

    # Merges all given receipts' line items and returns a hash that maps all
    # occuring articles ids to a hash that contains the merged quantities for
    # the article.
    #
    # @param [Array] receipts the list of receipts. It is expected that they
    #   implement #line_items_to_hash, an instance method that returns all
    #   occuring articles in a hash mapped to their quantities.
    #   It does not matter if the receipts are in an Array
    #   or if they are passed in as multiple arguments.
    #
    # @return [Hash] the merged quantities in the following form:
    #   { <article_id1> => { :quantitiy => <merged_quantities> },
    #   { <article_id2> ... }
    #
    # @example Merging multiple receipts
    #   receipt1.line_items_to_hash
    #   # => { 1 => { :quantity => 3 }, 4 => { :quantity => 2 } }
    #
    #   receipt2.line_items_to_hash
    #   # => { 1 => { :quantity => 2 }, 7 => { :quantity => 6 } }
    #
    #   ip_merge receipt1, receipt2 # same as ip_merge([receipt1, receipt2])
    #   # => { 1 => { :quantity => 5 },
    #          4 => { :quantity => 2 },
    #          7 => { :quantity => 6 } }
    def ip_merge(*receipts)
      if receipts.first.is_a? Array
        receipts = receipts.first
      end
      Merge.new(receipts).evaluate
    end

    # Substracts the subtrahend quantities from the minuend hash. See #ip_merge
    # documentation for a description of how the hashes have to be structured.
    #
    # @option options [Boolean] :inversed Flag that indicates if the resulting
    #   differences have to be inversed
    # @option options [Float] :tolerance Percental value that indicates when
    #   quantity difference is no longer tolerated
    def ip_sub(minuend, subtrahend, options = {})
      Sub.new(minuend, subtrahend, options).evaluate
    end
  end
  Object.send :include, ObjectExt
end
