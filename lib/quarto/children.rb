module Quarto
	module ElementWrapperChildren
		def self.included(base)
			base.extend(ClassMethods)
			base.class_eval do
				alias_method :method_missing_without_children, :method_missing
				alias_method :method_missing, :method_missing_with_children
				
				alias_method :respond_to_without_children?, :respond_to?
				alias_method :respond_to?, :respond_to_with_children?
			end
		end
		
		def method_missing_with_children(meth, *args)
			if self.class.has_children_named?(meth)
				children_proxy(meth)
			elsif self.class.has_parent_named?(meth)
				wrapped_parent
			else
				method_missing_without_children(meth, *args)
			end
		end
		
		def respond_to_with_children?(meth, include_private = false)
			if self.class.has_children_named?(meth) or self.class.has_parent_named?(meth)
				true
			else
				respond_to_without_children?(meth, include_private)
			end
		end
		
		protected
		
		def children_proxy(collection_el_name)
			@children_proxies ||= {}
			@children_proxies[collection_el_name.to_s] ||= Children.new(self, collection_el_name.to_s.singularize)
		end
		
		def wrapped_parent
			parent_el_name = self.class.read_inheritable_attribute(:parent)
			parent_class_name = parent_el_name.classify
			Kernel.const_get(parent_class_name).new(@element.parent.parent) # Go up two levels, since each child is expected to be inside a collection element
		end
		
		module ClassMethods
			def children(el_name)
				write_inheritable_array(:children, [el_name.to_s])
			end
			
			def has_children_named?(collection_el_name)
				return false if read_inheritable_attribute(:children).nil?
				read_inheritable_attribute(:children).include?(collection_el_name.to_s)
			end
			
			def has_parent_named?(parent_el_name)
				read_inheritable_attribute(:parent) == parent_el_name.to_s
			end
			
			def parent(el_name)
				write_inheritable_attribute(:parent, el_name.to_s)
			end
		end
	end
	
	class Children
		include Enumerable
		
		attr_reader :collection_element
		
		def each
			to_a.each { |child| yield child }
		end
		
		def empty?
			to_a.empty?
		end
		
		def initialize(wrapped_parent, el_name, options = {})
			@wrapped_parent = wrapped_parent
			@el_name = el_name.to_s
			@collection_element = @wrapped_parent.element.elements[options[:collection_el_name] ||  @el_name.pluralize]
			@wrapper_class = options[:wrapper_class] || Kernel.const_get(@el_name.classify)
		end
		
		def length
			to_a.length
		end
		
		# xpath is relative to the parent element
		def to_a(xpath = nil)
			@all ||= @collection_element.elements.to_a(xpath || @el_name).collect do |el|
				@wrapper_class.new(el)
			end
		end
		
		alias_method :size, :length
	end
end

Quarto::ElementWrapper.send(:include, Quarto::ElementWrapperChildren)