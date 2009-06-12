require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::Transformer do
	include Quarto::REXMLMatchers
	
	context '#transform' do
		before :each do
			@xml = %q(
				<doc>
					<div>
						<p>Foo</p>
						<p>Bar</p>
						
						<book>
							<title>Foobar</title>
							<author>Baz</author>
							<cover_url>http://example.com/foobar.jpeg</cover_url>
						</book>
					</div>
				</doc>
			)
			@doc = REXML::Document.new(@xml)
			
			class TestTransformer < Quarto::Transformer
				def literal?(element)
					['doc', 'div', 'p'].include?(element.name)
				end
			end
			
			@t = TestTransformer.new
		end
		
		after :each do
			Object.class_eval do
				remove_const :TestTransformer
			end
		end
		
		it 'should return a string' do
			@t.transform(@doc).should be_a(String)
		end
		
		it 'should not transform elements that lack custom transform methods and for which literal? returns true' do
			result = REXML::Document.new(@t.transform(@doc))
			result.should have_element('doc')
			result.should have_element('div')
			result.should have_element('p', :text => 'Foo')
			result.should have_element('p', :text => 'Bar')
		end
		
		it 'should ignore elements that lack custom transform methods and for which literal? returns false' do
			result = REXML::Document.new(@t.transform(@doc))
			['book', 'title', 'author' 'cover_url'].each do |el|
				result.should_not have_element(el)
			end
		end
		
		it 'should use custom transform methods' do
			begin
				class CustomizedTestTransformer < TestTransformer
					def transform_book(book_element, raise_on_unrecognized_element)
						%Q(
							<div class="book">
								<h1 class="title">#{book_element.elements['title'].text}</h1>
								<h2 class="author">#{book_element.elements['author'].text}</h2>
								<img src="#{book_element.elements['cover_url'].text}"/>
							</div>
						)
					end
				end
			
				t = CustomizedTestTransformer.new
				result = REXML::Document.new(t.transform(@doc))
				result.should have_element('div', :attributes => {'class' => 'book'})
				result.should have_element('h1', :attributes => {'class' => 'title'}, :text => 'Foobar')
				result.should have_element('h2', :attributes => {'class' => 'author'}, :text => 'Baz')
				result.should have_element('img', :attributes => {'src' => 'http://example.com/foobar.jpeg'})
			ensure
				Object.class_eval do
					remove_const :CustomizedTestTransformer
				end
			end
		end
		
		it 'should give precedence to custom transform methods over literal?' do
			begin
				class CustomizedTestTransformer < TestTransformer
					def transform_p(p_element, raise_on_unrecognized_element)
						%x(<div class="paragraph">#{p_element.text}</div>)
					end
				end
			
				t = CustomizedTestTransformer.new
				result = REXML::Document.new(t.transform(@doc))
				
				raise 'not implemented'
			ensure
				Object.class_eval do
					remove_const :CustomizedTestTransformer
				end
			end				
		end
	end
	
	context '#element' do
		it 'should return a REXML::Element with the given name' do
			raise 'not implemented'
		end
		
		it 'should attach the given attributes to the created element' do
			raise 'not implemented'
		end
		
		it 'should not require attributes' do
			raise 'not implemented'
		end
		
		it 'should create a tree if a block is given' do
			raise 'not implemented'
		end
	end
	
	context '.literals' do
		before :each do
			class TestTransformer < Quarto::Transformer
				literals :doc, :div, 'p'
			end
		end
		
		after :each do
			Object.class_eval do
				remove_const :TestTransformer
			end
		end
		
		it 'should define literal? so that it returns true for any element on the list and false for any other' do
			raise 'not implemented'
		end
		
		it 'should have no effect if literal? is subsequently defined' do
			class TestTransformer < Quarto::Transformer
				def literal?(element)
					false
				end
			end
			
			raise 'not implemented'
		end
	end
end