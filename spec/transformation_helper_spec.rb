require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::TransformationHelper do
	include Quarto::TransformationHelper
	
	context '#tranform_xml' do
		before :each do
			@html = REXML::Document.new(%Q(
				<div>
					<p>Foo</p>
					<p><a href="http://example.com">Bar</a></p>
				</div>
			))
		end
		
		it 'should return a string' do
			transform_xml(@html).should be_a(String)
			transform_xml(@html.root).should be_a(String)
		end
		
		it 'should raise if passed anything other than a REXML::Element' do
			lambda { transform_xml(nil) }.should raise_error(ArgumentError, 'Expected REXML::Element but got nil')
			lambda { transform_xml('foo') }.should raise_error(ArgumentError, 'Expected REXML::Element but got "foo"')
		end
		
		context 'without transformer_class given' do
			it 'should use HtmlTransformer' do
				t = Quarto::HtmlTransformer.new
				Quarto::HtmlTransformer.should_receive(:new).and_return(t)
				transform_xml(@html)
			end
		end
	end
end