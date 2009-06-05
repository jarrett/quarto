module Quarto
	# ElementWrapper::Base subclasses can define parent and child elements, resulting
	# in handy accessor methods. For example:
	#
	#   class Company < ElementWrapper::Base
	#     children :employees
	#   end
	#   
	#   class Employee < ElementWrapper::Base
	#     parent :company
	#     element_attr 'name'
	#   end
	#   
	#   # in generate.rb:
	#   company = Company.find :first
	#   company.employees.each do |employee|
	#     puts employee.name
	#   end
	
	module ElementWrapper
		module Children
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
			
			def children_proxy(meth) # :nodoc:
				@children_proxies ||= {}
				options = self.class.read_inheritable_attribute(:children).detect { |hash| hash[:method] == meth }
				@children_proxies[meth] ||= ChildrenProxy.new(self, meth.to_s.singularize, options)
			end
			
			def wrapped_parent # :nodoc:
				parent_el_name = self.class.read_inheritable_attribute(:parent)
				parent_class_name = parent_el_name.classify
				Kernel.const_get(parent_class_name).new(@element.parent.parent) # Go up two levels, since each child is expected to be inside a collection element
			end
			
			module ClassMethods # :nodoc:
				# :singleton_method:
				# Creates an attribute for a child element. +el_name+ must be the singular form. Example:
				#
				#   <company>
				#     <boss>
				#       <name>Joe Schmoe</name>
				#     </boss>
				#   </company>
				#
				#   class Company
				#     child :boss
				#   end
				def child(el_name, options = {})
					write_inheritable_array(:singleton_children, [el_name.to_s])
				end
				
				# :singleton-method:
				# Creates an attribute for child elements.
				# 
				# Options:
				# * <tt>:collection_element</tt> - In the XML, all children must be
				#   wrapped in a collection element whose name is +pluralized_el_name+
				#   unless the <tt>:collection_el_name</tt> option is given. If
				#   the child elements are not wrapped in a collection element at all,
				#   use <tt>:collection_el_name => nil</tt>.
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
				#   class Company < ElementWrapper::Base
				#     children :employees
				#   end
				def children(method_name, options = {})
					write_inheritable_array(:children, [options.merge({
						:method => method_name.to_sym,
						:el_name => method_name.to_s.singularize
					})])
				end
				
				def has_child_named?(singleton_child_el_name) # :nodoc:
					return false if read_inheritable_attribute(:singleton_children).nil?
					read_inheritable_attribute(:singleton_children).include?(singleton_child_el_name.to_s)
				end
				
				def has_children_named?(method_name) # :nodoc:
					return false if read_inheritable_attribute(:children).nil?
					!read_inheritable_attribute(:children).detect { |hash| hash[:method] == method_name.to_sym }.nil?
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
				#   class Employee < ElementWrapper::Base
				#     parent :company
				#   end
				def parent(el_name)
					write_inheritable_attribute(:parent, el_name.to_s)
				end
			end
		end
	
		class ChildrenProxy
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
				if options.has_key?(:collection_element)
					if options[:collection_element].nil?
						# The subclass says there is no collection element wrapping the children
						@collection_element = nil
					else
						@collection_element = @wrapped_parent.element.elements[options[:collection_element]]
					end
				else
					@collection_element = @wrapped_parent.element.elements[@el_name.pluralize]
				end
				@wrapper_class = options[:wrapper_class] || Kernel.const_get(@el_name.classify)
			end
			
			# Returns the number of children.
			def length
				to_a.length
			end
			
			# Returns an array of all children. Each is an instance of ElementWrapper::Base. If +xpath+ is provided, the results will be filtered. +xpath+ is relative to the parent element
			def to_a(xpath = nil)
				@all ||= (@collection_element || @wrapped_parent.element).elements.to_a(xpath || @el_name).collect do |el|
					@wrapper_class.new(el)
				end
			end
			
			alias_method :size, :length
		end
	end
end

Quarto::ElementWrapper::Base.send(:include, Quarto::ElementWrapper::Children)