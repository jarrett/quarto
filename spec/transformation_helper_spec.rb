require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::TransformationHelper do
	include Quarto::TransformationHelper
	
	context '#tranform_xml' do
		before :each do
			@html = REXML::Document.new(%q(
				<div>
					<p>Foo</p>
					<p><a href="http://example.com">Bar</a></p>
					<p>Baz&mdash;Baz</p>
				</div>
			))
			@bad_html = REXML::Document.new(%q(
				<div>
					<p>Foo</p>
					<bar>Baz</bar>
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
		
		it 'should raise on an unrecognized element by default' do
			lambda { transform_xml(@bad_html) }.should raise_error(Quarto::UnrecognizedElementError)
		end
		
		it 'should not raise on an unrecognized element if raise_on_unrecognized_element is false' do
			transform_xml(@bad_html, Quarto::HtmlTransformer, false)
		end
		
		context 'without transformer_class given' do
			it 'should use HtmlTransformer' do
				t = Quarto::HtmlTransformer.new
				Quarto::HtmlTransformer.should_receive(:new).and_return(t)
				transform_xml(@html)
			end
			
			it 'should return the original HTML' do
				REXML::Document.new(transform_xml(@html)).to_s.should == @html.to_s.strip
			end
		end
	end
end