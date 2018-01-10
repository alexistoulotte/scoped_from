require 'spec_helper'

describe ScopedFrom do

  describe '.version' do

    subject { ScopedFrom.version }

    it { should be_a(String) }
    it { should match(/^\d+\.\d+(\.\d+)?/) }

    it 'is freezed' do
      expect {
        ScopedFrom.version.gsub!('.', '#')
      }.to raise_error(/can't modify frozen string/i)
    end

  end

end
