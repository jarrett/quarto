module Quarto
	module REXMLMatchers
		class HaveElement
			def initialize(element_name, options)
				@element_name = element_name
				@options = options
			end
			
			def matches?(target)
				@target = target
				return false unless @target.is_a?(REXML::Element)
				!@target.find_first_recursive { |node| node_matches?(node) }.nil?
			end
			
			def failure_message
				if @target.is_a?(REXML::Element)
					"Expected element #{element_desc} to be in:\n\n#{@target.to_s}"
				else
					"Expected #{@target.inspect} to be a REXML::Element"
				end
			end
			
			def negative_failure_message
				if @target.is_a?(REXML::Element)
					"Expected element #{element_desc} not to be in:\n\n#{@target.to_s}"
				else
					"Expected #{@target.inspect} to be a REXML::Element"
				end
			end
			
			protected
			
			def element_desc
				desc = '<' + @element_name + '>'
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
				if node.name != @element_name
					return false
				end
				if @options.has_key?(:attributes) and rexml_attrs_to_hash(node.attributes) != @options[:attributes]
					return false
				end
				if @options.has_key?(:text) and node.text != @options[:text]
					return false
				end
				true
			end
			
			def rexml_attrs_to_hash(rexml_attrs)
				hash = {}
				rexml_attrs.each do |attr_name, value|
					hash[attr_name] = value
				end
				hash
			end
		end
		
		def have_element(element_name, options = {})
			HaveElement.new(element_name, options)
		end
	end
end