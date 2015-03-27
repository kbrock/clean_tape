require 'spec_helper'

describe CleanTape::Mapper do
  subject { described_class.new }

  describe "#fix_field" do
    it { expect(subject.fix_field("ip", nil)).to eq(nil) }
    it { expect(subject.fix_field("ip", "")).to eq("") }
    it { expect(subject.fix_field("x", "abc")).to eq("abc") }
  end

  describe "#fix_fields" do
    it { expect(subject.fix_fields("ip", nil)).to eq(nil) }
    it { expect(subject.fix_fields("ip", [])).to eq([]) }
    it { expect(subject.fix_fields("ip", %w(3.4.1.1 3.4.1.2))).to eq(%w(192.168.1.1 192.168.1.2)) }
    it { expect(subject.fix_fields("x", %w(3.4.1.1 3.4.1.2))).to eq(%w(3.4.1.1 3.4.1.2)) }
  end

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
