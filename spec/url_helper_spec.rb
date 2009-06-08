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
	
	context '#link_to' do
		it 'should be defined if RAILS_GEM_VERSION is not defined' do
			if defined? RAILS_GEM_VERSION
				raise 'RAILS_GEM_VERSION is defined. (It shouldn\'t be when running this spec)'
			end
			
			class TemplateOutsideRails
				include Quarto::UrlHelper
			end
			
			TemplateOutsideRails.new.should respond_to(:link_to)
			
			Object.class_eval do
				remove_const :TemplateOutsideRails
			end
		end
		
		it 'should not be redefined if RAILS_GEM_VERSION is defined' do
			RAILS_GEM_VERSION = 'foo'
			
			class RailsTemplate
				attr_reader :link_to_called
				
				def initialize
					@link_to_called = false
				end
				
				def link_to(*args)
					@link_to_called = true
				end
				
				include Quarto::UrlHelper
			end
			
			template = RailsTemplate.new
			template.link_to('bar')
			template.link_to_called.should == true
			
			Object.class_eval do
				remove_const :RailsTemplate
				remove_const :RAILS_GEM_VERSION
			end
		end
	end

	context '#url_for' do
		context 'outside Rails' do
			it 'should be defined' do
				if defined? RAILS_GEM_VERSION
					raise 'RAILS_GEM_VERSION is defined. (It shouldn\'t be when running this spec)'
				end
				
				class TemplateOutsideRails
					include Quarto::UrlHelper
				end
				
				TemplateOutsideRails.new.should respond_to(:url_for)
				
				Object.class_eval do
					remove_const :TemplateOutsideRails
				end
			end
		end

		context 'in Rails' do
			before :each do
				RAILS_GEM_VERSION = 'foo'
				
				class RailsTemplate
					attr_reader :url_for_called
					
					def initialize
						@url_for_called = false
					end
					
					def url_for(options = {})
						@url_for_called = true
					end
					
					include Quarto::UrlHelper
				end
			end
			
			after :each do
				Object.class_eval do
					remove_const :RAILS_GEM_VERSION
					remove_const :RailsTemplate
				end
			end
			
			it 'should pass the parameter through to the Rails url_for if the parameter is not an ElementWrapper::Base' do
				template = RailsTemplate.new
				template.url_for('bar')
				template.url_for_called.should == true
			end
		
			it 'should call to_path if the parameter is an ElementWrapper::Base and RAILS_GEM_VERSION is defined' do
				wrapper = mock
				wrapper.stub!(:to_path).and_return('some_path')
				wrapper.stub!(:is_a?).and_return(true)
				wrapper.should_receive(:is_a?).with(Quarto::ElementWrapper::Base).and_return(true)
				wrapper.should_receive(:to_path)
				template = RailsTemplate.new
				template.url_for(wrapper).should == 'some_path'
			end
		end
	end
end