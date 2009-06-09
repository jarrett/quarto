require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::Rendering do
	context '.render' do
		it 'should use the ERB template' do
			template = ERB.new 'foo bar'
			Quarto::Rendering.render(template, {}).should == 'foo bar'
		end
		
		it 'should set the local variables' do
			template = ERB.new 'The value of x is <%= x %>.'
			Quarto::Rendering.render(template, {:x => 42}).should == 'The value of x is 42.'
		end
		
		it 'should mix in the modules' do
			module SomeMixin
				def foo; 42; end
			end
			template = ERB.new 'SomeMixin#foo returns <%= foo %>.'
			Quarto::Rendering.render(template, {}, [SomeMixin]).should == 'SomeMixin#foo returns 42.'
			Object.class_eval do
				remove_const :SomeMixin
			end
		end
		
		it 'should raise ArgumentError if the first parameter is not an ERB template' do
			lambda { Quarto::Rendering.render('foo bar', {}) }.should raise_error(ArgumentError)
		end
		
		it 'should raise ArgumentError if the second parameter is not a hash' do
			template = ERB.new 'foo bar'
			lambda { Quarto::Rendering.render(template, [:x, 42]) }.should raise_error(ArgumentError)
		end
		
		it 'should raise ArgumentError if the third parameter is not an array of modules' do
			module SomeMixin; end
			template = ERB.new 'foo bar'
			lambda { Quarto::Rendering.render(template, {}, SomeMixin) }.should raise_error(ArgumentError)
			lambda { Quarto::Rendering.render(template, {}, [SomeMixin, 'foo']) }.should raise_error(ArgumentError)
			Object.class_eval do
				remove_const :SomeMixin
			end
		end
	end
end