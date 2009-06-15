require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::HtmlTransformer do
	include Quarto::REXMLMatchers
	
	context '#transform' do
		before :each do
			@html = REXML::Document.new(%Q(
				<description>
					<p id="first_paragraph">Mega-lo-Mart is a parody of big-box stores featured in <cite>King of the Hill</cite>.</p>
				
					<p id="second_paragraph">It is featured in Wikipedia's
						<a href="http://en.wikipedia.org/wiki/List_of_fictional_companies">List&nbsp;of&nbsp;Fictional&nbsp;Companies.</a>
					</p>
				</description>
			))
			@t = Quarto::HtmlTransformer.new
		end
		
		it 'should return valid HTML verbatim, even if the root element is not a valid HTML element' do
			output = @t.transform(@html.root)
			output = REXML::Document.new('<description>' + output + '</description>')
			output.should have_element('p', :attributes => {'id' => 'first_paragraph'})
			output.should have_element('cite', :text => 'King of the Hill')
			output.should have_element('p', :attributes => {'id' => 'second_paragraph'})
			output.should have_element('a', :attributes => {'href' => 'http://en.wikipedia.org/wiki/List_of_fictional_companies'})
		end
	end
end