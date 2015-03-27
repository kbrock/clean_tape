require 'spec_helper'

describe CleanTape::Mapper do
  subject { described_class.new }

  describe "#mac?" do
    it { expect(subject.mac?("mac")).to eq(true) }
    it { expect(subject.mac?("ip")).to eq(false) }
  end

  describe "#fix_mac" do
    it("fixes colons") { expect(subject.fix_mac("78:2b:cb:00:f6:6c")).to eq("00:00:00:00:f6:6c") }
    it("fixes dashes") { expect(subject.fix_mac("78-2b-cb-00-f6-6c")).to eq("00-00-00-00-f6-6c") }
  end

  describe "#ip?" do
    it { expect(subject.ip?("ip")).to eq(true) }
    it { expect(subject.ip?("name")).to eq(false) }
  end

  describe "#fix_ip" do
    it { expect(subject.fix_ip("5.150.3.4")).to eq("192.168.3.4") }
  end
end
