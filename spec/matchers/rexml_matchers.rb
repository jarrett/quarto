module Quarto
	module REXMLMatchers
		class HaveElement
			def initialize(element_name, options)
				@element_name = element_name
				@options = options
			end
			
			def matches?(target)
				@target = target
				!@target.find_first_recursive { |node| node_matches?(node) }.nil?
			end
			
			def failure_message
				"Expected element '#{element_desc}' to be in:\n\n#{@target.to_s}"
			end
			
			def negative_failure_message
				"Expected element '#{element_desc}' not to be in:\n\n#{@target.to_s}"
			end
			
			protected
			
			def element_desc
				desc = @element_name
				if @options.has_key?(:attributes)
					desc << " with attributes: #{@options[:attributes].inspect}"
					if @options.has_key?(:text)
						desc << " and text: '#{@options[:text]}'"
					end
				else
					if @options.has_key?(:text)
						desc << " with text: '#{@options[:text]}'"
					end
				end
				desc
			end
			
			def node_matches?(node)
				puts 'Looking for: ' + @element_name.inspect + ' Found: ' + node.name.inspect
				if node.name != @element_name
					return false
				end
				if @options.has_key?(:attributes) and node.attributes != @options[:attributes]
					return false
				end
				if @options.has_key?(:text) and node.text != @options[:text]
					return false
				end
				true
			end
		end
		
		def have_element(element_name, options = {})
			HaveElement.new(element_name, options)
		end
	end
end