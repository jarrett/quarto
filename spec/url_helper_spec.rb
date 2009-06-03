require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::UrlHelper do
	include Quarto::UrlHelper
	
	context '#urlize' do
		it 'should automatically convert non-strings to strings' do
			urlize(1).should == '1'
		end
		
		it 'should replace spaces with dashes' do
			urlize('John Smith').should == 'John-Smith'
		end
		
		it 'should not change numbers' do
			urlize('a10b').should == 'a10b'
		end
		
		it 'should not change dashes and underscores' do
			urlize('foo-bar_baz').should == 'foo-bar_baz'
		end
	end
end