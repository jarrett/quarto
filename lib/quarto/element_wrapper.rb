module Quarto
	# Abstract base class for your models. Put your ElementWrapper subclasses inside the "models"
	# directory within your project. All files in that directory will be automatically required.
	#
	# Each ElementWrapper subclass corresponds to exactly one XML element.
	# You can specify the model's element name by calling element_name=, but
	# generally, you just let ElementWrapper use the default, which is the subclass
	# name in snake_case.
	#
	# Instance attributes corresponding to the XML attributes 
	#
	# For example, suppose you have an XML document like this:
	#
	#   <programmers>
	#     <programmer skill="genius">
	#       <name>Linus Torvalds</name>
	#     <programmer>
	#   </programmers>
	#
	# You could then subclass ElementWrapper like this:
	#
	#   class Programmer < ElementWrapper
	#     element_name = 'programmer'
	#     element_attrs 'name'
	#   end
	#
	# You could then do something like this in your generate.rb file:
	#
	#   programmer = Programmer.find :first
	#   puts programmer.name
	#   puts programmer.skill
	#
	# Also see the documentation for Quarto::Children
	
	class ElementWrapper
		include InheritableAttributes
		
		# Returns true if both instances come from the same node in the source XML document.
		def ==(other_wrapped_element)
			other_wrapped_element.is_a?(Quarto::ElementWrapper) and @element == other_wrapped_element.element
		end
		
		# Returns the currently-loaded REXML::Document.
		def self.xml_doc
			Quarto.xml_doc
		end
		
		# Returns the REXML::Element from which the instance was created.
		attr_reader :element
		
		# Creates read-only attributes from the given strings. When a model is instantiated from an XML node,
		# ElementWrapper will try to populate these attributes using the node's child elements.
		#
		# For example, if your "employee" element has a child element called "name," you can use:
		#
		#   element_attrs 'name'
		#
		# ...which will then expose a #name method for every instance of your class. Also see the usage example in the class description.
		#
		# Remember, XML attributes will automatically have corresponding ElementWrapper attributes. You only need to tell
		# ElementWrapper which child elements to use.		
		def self.element_attrs(*element_names)
			write_inheritable_array :element_attrs, element_names.collect { |en| en.to_sym}
		end
		
		# Returns the XML element name.
		def self.element_name
			@element_name
		end
		
		# Overrides the XML element name. The default is the class name in snake_case.
		def self.element_name=(el_name)
			@element_name = el_name
		end
		
		# Searches the XML document and returns instances of the class. The first parameter must be either :first, :last, or :all.
		# If it's :first or :last, the method returns a single instance or nil. If it's :all, the method returns an array (which may be empty).
		#
		# Options:
		#
		# * <tt>:xpath</tt> - An XPath expression to limit the search. If this option is not given, the default XPath is "//element_name"
		def self.find(quantifier, options = {})
			raise ArgumentError, "Quantifier must be :all, :first, or :last, but got #{quantifier.inspect}" unless [:all, :first, :last].include?(quantifier)
			raise ArgumentError, "Options must be a Hash, but got #{options.inspect}" unless options.is_a?(Hash)
			if options.has_key?(:xpath)
				xpath = options[:xpath]
			else
				xpath = "//#{@element_name}"
				# TODO: add support for :root and :conditions (XPath predicates)
			end
			all = xml_doc.elements.to_a(xpath).collect do |el|
				new(el)
			end
			case quantifier
			when :all
				all
			when :first
				all.first
			when :last
				all.last
			end
		end
		
		def self.inherited(subclass) # :nodoc:
			subclass.element_name = subclass.to_s.underscore
		end
		
		def initialize(el) # :nodoc:
			unless el.is_a?(REXML::Element)
				raise ArgumentError, "Quarto::ElementWrapper.new must be passed a REXML::Element, but got #{el.inspect}"
			end
			@element = el
			@attributes = {}
			@element.attributes.each do |a_name, value|
				@attributes[a_name.to_sym] = typecast_text(value)
			end
			self.class.read_inheritable_attribute(:element_attrs).each do |el_name|
				raise ArgumentError, "Expected <#{@element.name}> to contain <#{el_name}>" if @element.elements[el_name.to_s].nil?
				@attributes[el_name.to_sym] = typecast_text(@element.elements[el_name.to_s].text)
			end
		end
		
		def method_missing(meth, *args, &block) # :nodoc:
			if @attributes.has_key?(meth.to_sym)
				@attributes[meth.to_sym]
			elsif @element.respond_to?(meth)
				@element.send(meth, *args, &block)
			else	
				super
			end
		end
		
		def respond_to?(meth, include_private = false) # :nodoc:
			if @element.respond_to?(meth, include_private) or @attributes.has_key?(meth.to_sym)
				true
			else
				super
			end
		end
		
		protected
		
		# When an ElementWrapper is instantiated from an XML node, all values start out as strings. This method typecasts those values.
		def typecast_text(t)
			if t.nil? or (t.is_a?(String) and t.empty?)
				nil
			elsif t =~ /^-?[0-9]+$/
				t.to_i
			elsif t =~ /^-?[0-9]*\.[0-9]+$/
				t.to_f
			else
				t
			end
		end
	end
end