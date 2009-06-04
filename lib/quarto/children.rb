module Quarto
	# ElementWrapper subclasses can define parent and child elements, resulting
	# in handy accessor methods. For example:
	#
	#   class Company < ElementWrapper
	#     children :employees
	#   end
	#   
	#   class Employee < ElementWrapper
	#     parent :company
	#     element_attr 'name'
	#   end
	#   
	#   # in generate.rb:
	#   company = Company.find :first
	#   company.employees.each do |employee|
	#     puts employee.name
	#   end
	
	module ElementWrapperChildren
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.class_eval do
				alias_method :method_missing_without_children, :method_missing
				alias_method :method_missing, :method_missing_with_children
				
				alias_method :respond_to_without_children?, :respond_to?
				alias_method :respond_to?, :respond_to_with_children?
			end
		end
		
		def method_missing_with_children(meth, *args) # :nodoc:
			if self.class.has_children_named?(meth)
				children_proxy(meth)
			elsif self.class.has_parent_named?(meth)
				wrapped_parent
			else
				method_missing_without_children(meth, *args)
			end
		end
		
		def respond_to_with_children?(meth, include_private = false) # :nodoc:
			if self.class.has_children_named?(meth) or self.class.has_parent_named?(meth)
				true
			else
				respond_to_without_children?(meth, include_private)
			end
		end
		
		protected
		
		def children_proxy(collection_el_name) # :nodoc:
			@children_proxies ||= {}
			@children_proxies[collection_el_name.to_s] ||= Children.new(self, collection_el_name.to_s.singularize)
		end
		
		def wrapped_parent # :nodoc:
			parent_el_name = self.class.read_inheritable_attribute(:parent)
			parent_class_name = parent_el_name.classify
			Kernel.const_get(parent_class_name).new(@element.parent.parent) # Go up two levels, since each child is expected to be inside a collection element
		end
		
		module ClassMethods # :nodoc:
			# :singleton-method:
			# Define children. +el_name+ must be the singular form. In the XML, all children must be
			# wrapped in a collection element whose name is the plural form.
			#
			#  Example:
			#
			#   <company>
			#     <employees>
			#       <employee>
			#       </employee>
			#     </employees>
			#   </company>
			#   
			#   class Company < ElementWrapper
			#     children :employees
			#   end
			def children(el_name)
				write_inheritable_array(:children, [el_name.to_s])
			end
			
			def has_children_named?(collection_el_name) # :nodoc:
				return false if read_inheritable_attribute(:children).nil?
				read_inheritable_attribute(:children).include?(collection_el_name.to_s)
			end
			
			def has_parent_named?(parent_el_name) # :nodoc:
				read_inheritable_attribute(:parent) == parent_el_name.to_s
			end
			
			# :singleton-method:
			# Defines the element's parent. Example:
			#  Example:
			#
			#   <company>
			#     <employees>
			#       <employee>
			#       </employee>
			#     </employees>
			#   </company>
			#   
			#   class Employee < ElementWrapper
			#     parent :company
			#   end
			def parent(el_name)
				write_inheritable_attribute(:parent, el_name.to_s)
			end
		end
	end
	
	class Children
		include Enumerable
		
		# Returns the REXML::Element for the children collection.
		attr_reader :collection_element
		
		# Iterate over all children.
		def each
			to_a.each { |child| yield child }
		end
		
		# Returns true if there are no children.
		def empty?
			to_a.empty?
		end
		
		def initialize(wrapped_parent, el_name, options = {}) # :nodoc:
			@wrapped_parent = wrapped_parent
			@el_name = el_name.to_s
			@collection_element = @wrapped_parent.element.elements[options[:collection_el_name] ||  @el_name.pluralize]
			@wrapper_class = options[:wrapper_class] || Kernel.const_get(@el_name.classify)
		end
		
		# Returns the number of children.
		def length
			to_a.length
		end
		
		# Returns an array of all children. Each is an instance of ElementWrapper. If +xpath+ is provided, the results will be filtered. +xpath+ is relative to the parent element
		def to_a(xpath = nil)
			@all ||= @collection_element.elements.to_a(xpath || @el_name).collect do |el|
				@wrapper_class.new(el)
			end
		end
		
		alias_method :size, :length
	end
end

Quarto::ElementWrapper.send(:include, Quarto::ElementWrapperChildren)