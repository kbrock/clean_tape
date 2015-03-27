require 'spec_helper'

describe CleanTape::Mapper do
  subject { described_class.new }

  describe "#fix_mac" do
    it "cleans macs with colons" do
      expect(subject.fix_mac("78:2b:cb:00:f6:6c")).to eq("00:00:00:00:f6:6c")
    end

    it "cleans macs with dashes" do
      expect(subject.fix_mac("78-2b-cb-00-f6-6c")).to eq("00-00-00-00-f6-6c")
    end
  end
end
