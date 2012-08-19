require 'spec_helper'

describe ItemsProcessor do
  describe ".merge" do
    it "should exist" do
      ItemsProcessor.should respond_to :merge
    end
  end
  
  describe ".sub" do
    it "should exist" do
      ItemsProcessor.should respond_to :sub
    end
  end
end