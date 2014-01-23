require 'spec_helper'

describe Kernel do
  let(:receipt1) do
    double("receipt1", :line_items_to_hash => {
      1 => {
        :quantity       => 12,
        :price_value    => 10,
        :price_currency => "USD"
      },
      2 => {
        :quantity       => 8,
        :price_value    => 9,
        :price_currency => "USD"
      }
    })
  end

  let(:receipt2) do
    double("receipt2", :line_items_to_hash => {
      1 => {
        :quantity       => 12,
        :price_value    => 4,
        :price_currency => "USD"
      },
      2 => {
        :quantity       => 8,
        :price_value    => 9,
        :price_currency => "USD"
      },
      3 => {
        :quantity       => 3,
        :price_value    => 9,
        :price_currency => "USD"
      }
    })
  end

  describe "#ip_merge" do
    it "should merge quantities for common articles" do
      merged_hash = ip_merge receipt1, receipt2
      merged_hash[1][:quantity].should == 24
      merged_hash[2][:quantity].should == 16
      merged_hash[3][:quantity].should == 3
    end

    it "should be deterministic" do
      ip_merge(receipt1, receipt2).should == ip_merge(receipt1, receipt2)
    end

    it "should be symmetric" do
      ip_merge(receipt1, receipt2).should == ip_merge(receipt2, receipt1)
    end
  end

  describe "#ip_sub" do
    it "should substract quantities and prices for common articles" do
      diff_hash = ip_sub(
        receipt1.line_items_to_hash,
        receipt2.line_items_to_hash
      )
      diff_hash[1][:quantity].should == 0
      diff_hash[2][:quantity].should == 0
      diff_hash[3][:quantity].should == -3

      diff_hash[1][:price_value].should == 6
      diff_hash[2][:price_value].should == 0
      diff_hash[3][:price_value].should == 9
    end

    it "should be deterministic" do
      receipt1_hash = receipt1.line_items_to_hash
      receipt2_hash = receipt2.line_items_to_hash
      ip_sub(receipt1_hash, receipt2_hash)[1][:quantity].should == 0
      ip_sub(receipt1_hash, receipt2_hash)[1][:quantity].should == 0
    end
  end
end
