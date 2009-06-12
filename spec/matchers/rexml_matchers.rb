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
				"Expected element '#{@element_name}' to be in:\n\n#{@target.to_s}"
			end
			
			def negative_failure_message
				"Expected element '#{@element_name}' not to be in:\n\n#{@target.to_s}"
			end
			
			protected
			
			def node_matches?(node)
				if node.name != @element_name
					return false
				end
				if @options.has_key?(:attributes) and node.attributes != @options[:attributes]
					return false
				end
				if @options.has_key?(:text) and node.text != @options[:text]
					return false
				end
			end
		end
		
		def have_element(element_name, options = {})
			HaveElement.new(element_name, options)
		end
	end
end