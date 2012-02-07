require 'spec_helper'

describe ScopedFrom do
  
  describe '.version' do
    
    it 'is a string' do
      ScopedFrom.version.should be_a(String)
    end
    
    it 'is with correct format' do
      ScopedFrom.version.should match(/^\d+\.\d+(\.\d+)?/)
    end
    
    it 'is freezed' do
      expect {
        ScopedFrom.version.gsub!('.', '#')
      }.to raise_error(/can't modify frozen string/i)
    end
    
  end
  
end
