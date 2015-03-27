require 'spec_helper'
require 'json'

describe CleanTape::BodyCleaner do
  subject { described_class.new(YAML) }

  describe "str (helper function)" do
    it { expect(str('key' => 'value')).to eq(%Q{---\nkey: value\n}) }
  end

  describe "simple classes" do
    it { expect(subject.clean(nil)).to be_nil }
    # doesn't support simple types
    #it { expect(subject.clean("")).to be_nil } #FAIL
  end

  describe "arrays" do
    it { expect(subject.clean(str([]))).to eq(%Q{--- []\n})}
  end

  describe "hashes" do
    it { expect(subject.clean(str('key' => nil))).to eq(%Q{---\nkey: \n}) }
    it { expect(subject.clean(str('key' => ""))).to eq(%Q{---\nkey: ''\n}) }
    it { expect(subject.clean(str('key' => 'value'))).to eq(%Q{---\nkey: value\n}) }
    it { expect(subject.clean(str('key' => 1))).to eq(%Q{---\nkey: 1\n}) }
    it { expect(subject.clean(str('key' => true))).to eq(%Q{---\nkey: true\n}) }
    it { expect(subject.clean(str('key' => false))).to eq(%Q{---\nkey: false\n}) }
  end

  describe "complex hashes" do
    it { expect(subject.clean(str('ip' => nil))).to eq(%Q{---\nip: \n}) }
    it { expect(subject.clean(str('ip' => ""))).to eq(%Q{---\nip: ''\n}) }
    it { expect(subject.clean(str('ip' => '250.0.250.5'))).to eq(%Q{---\nip: 192.168.250.5\n}) }

    it { expect(subject.clean(str('key' => []))).to eq(%Q{---\nkey: []\n}) }
    it { expect(subject.clean(str('key' => %w(a b)))).to eq(%Q{---\nkey:\n- a\n- b\n}) }
    it { expect(subject.clean(str('ip' => []))).to eq(%Q{---\nip: []\n}) }
    it "{ip:[1,2]}" do
      expect(subject.clean(str('ip' => %w(1.1.1.1 1.1.1.2)))).to eq(%Q{---\nip:\n- 192.168.1.1\n- 192.168.1.2\n})
    end
  end

  describe "dested hashes and arrays" do
    it("[{ip:#},{x:a}]") do
      expect(subject.clean(str([{"ip" => "1.1.1.1"},{"x" => "a"}])))
        .to eq(%Q{---\n- ip: 192.168.1.1\n- x: a\n})
    end

    it("{x:{ip:[]}}") do
      expect(subject.clean(str("x" => {"ip" => %w{1.1.1.1}})))
        .to eq(%Q{---\nx:\n  ip:\n  - 192.168.1.1\n})
    end

    it("{x:[{ip:[]}]}") do
      expect(subject.clean(str("x" => [{"ip" => %w{1.1.1.1}}])))
        .to eq(%Q{---\nx:\n- ip:\n  - 192.168.1.1\n})
    end
  end
  
  private

  def str(obj)
    YAML.dump(obj)
  end
end
