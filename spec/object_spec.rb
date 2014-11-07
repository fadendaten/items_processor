require 'spec_helper'

describe Object do
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
        :quantity       => 1,
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
    let(:all_receipts) { [receipt1, receipt2] }
    it "should merge quantities for common articles" do
      merged_hash = ip_merge all_receipts
      merged_hash[1][:quantity].should == 13
      merged_hash[2][:quantity].should == 16
      merged_hash[3][:quantity].should == 3
    end

    it "should be deterministic" do
      ip_merge(all_receipts).should == ip_merge(all_receipts)
    end
  end

  describe "#ip_sub" do
    it "should substract quantities and prices for common articles" do
      diff_hash = ip_sub(
        receipt1.line_items_to_hash,
        receipt2.line_items_to_hash
      )
      diff_hash[1][:quantity].should == 11
      diff_hash[2][:quantity].should == 0
      diff_hash[3][:quantity].should == -3

      diff_hash[1][:price_value].should == 6
      diff_hash[2][:price_value].should == 0
      diff_hash[3][:price_value].should == -9
    end

    it "should be deterministic" do
      receipt1_hash = receipt1.line_items_to_hash
      receipt2_hash = receipt2.line_items_to_hash
      ip_sub(receipt1_hash, receipt2_hash)[1][:quantity].should == 11
      ip_sub(receipt1_hash, receipt2_hash)[1][:quantity].should == 11
    end

    context "when a :tolerance option is given" do
      it "should nest a { :tolerated => true|false } hash for each article whereas the value
          indicates if the percental diff is less than the given :tolerance value" do
        tolerance = 5 # percent
        diff_hash = ip_sub(
          receipt1.line_items_to_hash,
          receipt2.line_items_to_hash,
          :tolerance => tolerance
        )
        diff_hash[1][:tolerated].should == false
        diff_hash[2][:tolerated].should == true
      end
    end

    context "when :inversed option is set to true" do
      it "should return inverted diff quantities and prices" do
        diff_hash = ip_sub(
          receipt1.line_items_to_hash,
          receipt2.line_items_to_hash,
          :inversed => true
        )
        diff_hash[1][:quantity].should == -11
        diff_hash[2][:quantity].should == 0
        diff_hash[3][:quantity].should == 3

        diff_hash[1][:price_value].should == -6
        diff_hash[2][:price_value].should == 0
        diff_hash[3][:price_value].should == 9
      end
    end

    context "when minuend and subtrahend both have articles that the other
             one does not" do
      let(:minuend) do
        {
          1 => { :quantity => 2 },
          2 => { :quantity => 3 }
        }
      end

      let(:subtrahend) do
        {
          1 => { :quantity => 2 },
          3 => { :quantity => 5 }
        }
      end

      it "should return a diff that contains all article ids" do
        diff_hash = ip_sub minuend, subtrahend
        diff_hash.keys.should include 1, 2, 3

        diff_hash[1][:quantity].should == 0
        diff_hash[2][:quantity].should == 3
        diff_hash[3][:quantity].should == -5
      end
    end
  end
end
