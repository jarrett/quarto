require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'uri'

describe Quarto::UrlHelper do
	include Quarto::UrlHelper
	
	context '#urlize' do
		it 'should automatically convert non-strings to strings' do
			urlize(1).should == '1'
		end
		
		it 'should replace spaces with dashes' do
			urlize('John Smith').should == 'John-Smith'
		end
		
		it 'should not change numbers without decimal points' do
			['10', '-1', 'a10b'].each do |num|
				urlize(num).should == num
			end
		end
		
		it 'should remove the . character' do
			[
				['foo.bar', 'foobar'],
				['.foo', 'foo'],
				['foo.', 'foo'],
				['10.5', '105']
			].each do |input, expected|
				urlize(input).should == expected
			end
		end
		
		it 'should not change dashes and underscores' do
			urlize('foo-bar_baz').should == 'foo-bar_baz'
		end
	end
	
	context '#link_to' do
		context 'outside Rails' do
			before :each do
				if defined? RAILS_GEM_VERSION
					raise 'RAILS_GEM_VERSION is defined. (It shouldn\'t be when running this spec)'
				end
				
				class TemplateOutsideRails
					include Quarto::UrlHelper
				end
			end
			
			after :each do
				Object.class_eval do
					remove_const :TemplateOutsideRails
				end
			end
			
			it 'should be defined' do
				TemplateOutsideRails.new.should respond_to(:link_to)
			end
			
			it 'should call url_for' do
				template = TemplateOutsideRails.new
				template.should_receive(:url_for)
				template.link_to('foo', 'bar')
			end
			
			it 'should return an HTML link' do
				expected = '<a href="http://example.com/foo">foo</a>'
				TemplateOutsideRails.new.link_to('foo', 'http://example.com/foo').should == expected
			end
			
			it 'should use :html_options' do
				expected = '<a href="http://example.com" onclick="javascript:alert(\'foo\');">Click me</a>'
				template = TemplateOutsideRails.new
				template.link_to(
					'Click me', 'http://example.com',
					:html_options => {:onclick => 'javascript:alert(\'foo\');'}
				).should == expected
			end
		end
		
		context 'in Rails' do
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
	end

	context '#url_for' do
		context 'outside Rails' do
			before :each do
				if defined? RAILS_GEM_VERSION
					raise 'RAILS_GEM_VERSION is defined. (It shouldn\'t be when running this spec)'
				end
				
				class TemplateOutsideRails
					include Quarto::UrlHelper
				end
			end
			
			after :each do
				Object.class_eval do
					remove_const :TemplateOutsideRails
				end
			end
			
			it 'should be defined' do
				TemplateOutsideRails.new.should respond_to(:url_for)
			end
			
			it 'should raise ArgumentError if anything other than a string or an instance of ElementWrapper::Base is passed to it' do
				class MockWrapper
					def is_a?(klass); Quarto::ElementWrapper::Base == klass; end	
					def to_path; 'foo'; end;
				end
				TemplateOutsideRails.new.url_for('foo')
				TemplateOutsideRails.new.url_for(MockWrapper.new)
				[1, 0.1, Date.new, URI.parse('http://foo.com')].each do |obj|
					lambda { TemplateOutsideRails.new.url_for(obj) }.should raise_error(ArgumentError)
				end
				Object.class_eval do
					remove_const :MockWrapper
				end
			end
			
			it 'should not call abs_url or abs_path' do
				['foo', '../foo', '/foo'].each do |rel_url|
					template = TemplateOutsideRails.new
					template.should_not_receive(:abs_url)
					template.should_not_receive(:abs_path)
					template.url_for(rel_url)
				end
			end
			
			it 'should not modify a url, be it absolute or relative' do
				['http://example.com', 'http://example.com/foo', 'https://example.com', 'ftp://example.com',
				'foo', '../foo', '/foo'].each do |url|
					TemplateOutsideRails.new.url_for(url).should == url
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
	
	context '#relative_path' do
		before :all do
			class MockRendering
				include Quarto::UrlHelper
				
				def initialize(output_file_path)
					@output_file_path = output_file_path
				end
				
				attr_accessor :output_file_path
			end
		end
		
		after :all do
			Object.class_eval do
				remove_const :MockRendering
			end
		end
		
		it 'should call output_file_path' do
			rendering = MockRendering.new('employees')
			rendering.should_receive('output_file_path').and_return('employees')
			rendering.relative_path('images/foo.jpg')
		end
		
		it 'should derive the correct relative path from output_file_path to the given file' do
			rendering = MockRendering.new('employees')
			rendering.relative_path('images/foo.jpg').should == '../images/foo.jpg'
		end
		
		it 'should work for complex directory structures' do
			[
				['countries/companies/employees', 'assets/images/foo.jpg', '../../../assets/images/foo.jpg'],
				['a/b/c/d/e/f', 'a/b/z', '../../../../z'],
				['a/b/z', 'a/b/c/d/e/f', '../c/d/e/f']
			].each do |output_file_path, target, expected|
				rendering = MockRendering.new(output_file_path)
				rendering.relative_path(target).should == expected
			end
		end
	end
end