module Quarto
	class ElementWrapper
		include InheritableAttributes
		
		def self.xml_doc
			Quarto.xml_doc
		end
		
		def self.element_attrs(*element_names)
			write_inheritable_array :element_attrs, element_names.collect { |en| en.to_sym}
		end
		
		def self.element_name
			@element_name
		end
		
		def self.element_name=(el_name)
			@element_name = el_name
		end
		
		def self.find(quantifier, options = {})
			raise ArgumentError, "Quantifier must be :all, :first, or :last, but got #{quantifier.inspect}" unless [:all, :first, :last].include?(quantifier)
			raise ArgumentError, "Options must be a Hash, but got #{options.inspect}" unless options.is_a?(Hash)
			if options.has_key?(:xpath)
				all = xml_doc.elements.to_a(options[:xpath]).collect do |el|
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
			else
				raise ArgumentError, 'In this beta version of Quarto, the :xpath option is mandatory. Later versions will feature other search methods.'
				# TODO: add support for :root and :conditions (XPath predicates)
			end
		end
		
		def self.inherited(subclass)
			subclass.element_name = element_name_from_class(subclass)
		end
		
		def initialize(el)
			unless el.is_a?(REXML::Element)
				raise ArgumentError, "Quarto::ElementWrapper.new must be passed a REXML::Element, but got #{el.inspect}"
			end
			@element = el
			@attributes = {}
			@element.attributes.each do |a_name, value|
				@attributes[a_name.to_sym] = typecast_text(value)
			end
			self.class.read_inheritable_attribute(:element_attrs).each do |el_name|
				@attributes[el_name.to_sym] = typecast_text(@element.elements[el_name.to_s].text)
			end
		end

		def method_missing(meth, *args)
			if @attributes.has_key?(meth.to_sym)
				@attributes[meth.to_sym]
			elsif @element.respond_to?(meth)
				@element.send(meth, *args)
			else	
				super
			end
		end
		
		def respond_to?(meth, include_private = false)
			if @element.respond_to?(meth, include_private) or @attributes.has_key?(meth.to_sym)
				true
			else
				super
			end
		end
		
		protected
	
		def self.element_name_from_class(klass)
			# Thanks to ActiveSupport for this algorithm
			klass.to_s.split('::').last.
			gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
			gsub(/([a-z\d])([A-Z])/,'\1_\2').
			tr("-", "_").
			downcase
		end
		
		def typecast_text(t)
			if t.empty?
				nil
			elsif t =~ /^-?[0-9]+$/
				t.to_i
			elsif t =~ /^-?[0-9]*\.[0-9]+$/
				t.to_f
			else
				begin
					DateTime.parse(t)
				rescue ArgumentError
					t
				end
			end
		end
	end
end