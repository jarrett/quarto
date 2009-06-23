module Quarto
	# This abstract base class is a substitute for XSLT. Its
	# <tt>transform</tt> method takes a single
	# <tt>REXML::Element</tt> and applies rules defined in
	# the subclass.
	#
	# To define those rules, you subclass Transformer and
	# write methods to handle each element type. For example:
	#
	#   class MyTranformer < Quarto::Transformer
	#     # This method will handle all <book> elements
	#     def transform_book(book_element, raise_on_unrecognized_element)
	#        # Return whatever string you like
	#        # raise_on_unrecognized_element is provided
	#        # so that you can pass it to recursive_transform
	#        # if necessary.
	#     end
	#   end
	class Transformer
		# Recursively applies the transformation rules
		# you've defined to +element+ and its children,
		# returning the results as a string. Depending
		# on the rules you've set up, the result may
		# be XML or something else altogether.
		#
		# +element+ must be a <tt>REXML::Element</tt>
		# or a subclass thereof. If +element+ is a
		# <tt>REXML::Document</tt>, the document root and all
		# its children will be transformed. If +element+
		# is a <tt>REXML::Element</tt>, only the element's
		# descendents will be tranformed; +element+ itself
		# will not be used.
		#
		# By default, unrecognized elements (and all their
		# descendants) will be ommited from the result tree.
		#
		# However, you can cause these unrecognized elements to
		# raise an exception by setting +raise_on_unrecognized_element+
		# to <tt>true</tt>.
		def transform(element, raise_on_unrecognized_element = false)
			raise ArgumentError, "Expected REXML::Element but got #{element.inspect}" unless element.is_a?(REXML::Element)
			if element.is_a?(REXML::Document)
				recursive_transform(element.root, raise_on_unrecognized_element)
			else
				element.children.to_a.inject('') do |result, child|
					result + recursive_transform(child, raise_on_unrecognized_element)
				end
			end
		end
		
		protected
		
		# Creates an XML tag with the specified name, returning a string.
		# This method is meant to be called by subclasses of
		# <tt>Transformer</tt>.
		#
		# Example:
		#
		#   content_tag('img', 'src' => 'http://example.com/image.jpg')
		#
		# If you need to use an absolute path for something, e.g. an image,
		# you should include <tt>Quarto::UrlHelper</tt> in your
		# <tt>Transformer</tt> subclass and call <tt>abs_path</tt>.
		def content_tag(tag_name, *args)
			if args.last.is_a?(Hash)
				attributes = args.pop
			else
				attributes = {}
			end
			if args.empty?
				if block_given?
					contents = yield
				else
					contents = nil
				end
			else
				contents = args[0]
			end
			output = "<#{tag_name}"
			attributes.each do |attr, value|
				output << " #{attr}=\"#{value}\""
			end
			if contents.nil? or contents.empty?
				output << '/>'
			else
				output << ">#{contents}</#{tag_name}>"
			end
		end
		
		# This method is meant to be overriden in subclasses. The
		# default implementation always returns false.
		#
		# When <tt>tranform</tt> is called, each descendant element
		# is passed to <tt>literal?</tt>. If it returns true,
		# the descdant is added to the result tree with the same
		# tag. If not, the <tt>Transformer</tt> will look for a
		# custom tranform method for that element. If none is found,
		# what happens next depends on the value of
		# <tt>raise_on_unrecognized_element</tt> in <tt>transform</tt>.
		# If it's true, an exception will be raised. Otherwise, the
		# element and its descendant will be ommitted from the result
		# tree.
		#
		# If <tt>literal?</tt> returns true for an element,
		# its descendant elements will not be added to the tree
		# verbatim, but will instead be subjected to the same
		# transformation process as everything else.
		#
		# See <tt>HtmlTransformer</tt> for an example implementation.
		def literal?(element)
			false
		end
		
		# Macro to define the <tt>literal?</tt> method. Accepts
		# one or more element names.
		#
		# Example:
		#
		#   class MyTransformer < Quarto::Transformer
		#     literals 'div', 'p', 'a'
		#   end
		#
		# The above is equivalent to:
		#
		#   class MyTransformer < Quarto::Transformer
		#     def literal?(element)
		#       ['div', 'p', 'a'].include?(element.name)
		#     end
		#   end 
		def self.literals(*args)
			class_eval(%Q(
				def literal?(element)
					[#{args.collect { |e| "'#{e}'" }.join(',')}].include?(element.name)
				end
			))
		end
		
		# Recursively transform the +element+ and all its children,
		# returning a string. Custom transform methods often call
		# this method.
		def recursive_transform(element, raise_on_unrecognized_element)
			if element.is_a?(REXML::Element)
				if respond_to?("transform_#{element.name}")
					send("transform_#{element.name}", element, raise_on_unrecognized_element)
				elsif literal?(element)
					contents = element.children.inject('') do |result, child|
						result + recursive_transform(child, raise_on_unrecognized_element)
					end
					content_tag(element.name, contents, element.attributes)
				elsif raise_on_unrecognized_element
					raise UnrecognizedElementError, "Unrecognized element: #{element.name}"
				else
					''
				end
			elsif element.is_a?(REXML::Comment)
				''
			else
				element.to_s
			end
		end
		
		# Replaces +element+ with +replace_with+, adding any
		# +attributes+. This is a convenience method for use
		# inside a custom transform method. It's not infinitely
		# flexible, but it simplifies a common task. Calls
		# recursive_transform on +element+'s children.
		def replace_element(element, replace_with, raise_on_unrecognized_element, attributes = {})
			raise ArgumentError, "Expected REXML::Element but got #{element.inspect}" unless element.is_a?(REXML::Element)
			raise ArgumentError, "Expected String but got #{replace_with.inspect}" unless replace_with.is_a?(String)
			raise ArgumentError, "Expected Hash but got #{attributes.inspect}" unless attributes.is_a?(Hash)
			contents = element.children.inject('') do |result, child|
				result + recursive_transform(child, raise_on_unrecognized_element)
			end
			content_tag(replace_with, contents, attributes)
		end
	end
	
	class UnrecognizedElementError < RuntimeError; end
end