module Quarto
	class ElementWrapper
		def self.element_name=(el_name)
			@element_name = el_name
		end
		
		def self.find(*args)
			quantifier = args.shift
			raise ArgumentError, "Expected :all, :first, or :last, but got #{quantifier.inspect}" unless [:all, :first, :last].include?(quantifier)
			args.each do |arg|
				raise ArgumentError, "Expected a Hash but got: #{arg.inspect}" unless arg.is_a?(Hash)
			end
			if args.has_key?(:xpath)
				@document.elements[args[:xpath]].collect do |el|
					from_element(el)
				end
			else
				raise ArgumentError, 'In this beta version of Quarto, the :xpath option is mandatory. Later versions will feature other search methods.'
				# TODO: add support for :root and :conditions (XPath predicates)
			end
		end
		
		def self.from_element(el)
			raise NotImplementedError, 'Subclasses must implement self.from_elements'
		end
		
		def self.inherited(subclass)
			@element_name = element_name_from_class_name(subclass.to_s)
		end
		
		def initialize(el)
			@element = el
		end
		
		def ivs_from_attributes(*attribute_names)
			attribute_names.each do |a_name|
				instance_variable_set "@#{a_name}", typecast_text(@element.attributes[a_name.to_s])
			end
		end
		
		def ivs_from_elements(*element_names)
			element_names.each do |el_name|
				instance_variable_set "@#{el_name}", typecast_text(@element[el_name.to_s].text)
			end
		end
		
		def method_missing(meth, *args)
			if @element.respond_to?(meth)
				@element.send(meth, *args)
			else
				super
			end
		end
		
		protected
	
		def self.element_name_from_class_name(class_name)
			# Thanks to ActiveSupport for this algorithm
			class_name.split['::'].last.
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