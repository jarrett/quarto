module Quarto
	module InheritableAttributes # :nodoc: all
		def self.included(base)
			base.extend(ClassMethods)
		end
		
		module ClassMethods
			def read_inheritable_attribute(key)
				@inheritable_attributes ||= {}
				@inheritable_attributes[key]
			end
			
			def write_inheritable_array(key, elements)
				write_inheritable_attribute(key, []) if read_inheritable_attribute(key).nil?
				write_inheritable_attribute(key, read_inheritable_attribute(key) + elements)
			end
			
			def write_inheritable_attribute(key, value)
				@inheritable_attributes ||= {}
				@inheritable_attributes[key] = value
			end
			
			def write_inheritable_hash(key, hash)
				write_inheritable_attribute(key, {}) if read_inheritable_attribute(key).nil?
				write_inheritable_attribute(key, read_inheritable_attribute(key).merge(hash))
			end
		end
	end
end