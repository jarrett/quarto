module Quarto
	class Rendering # :nodoc: all
		def initialize(__erb_template, __locals, __mixins)
			unless __erb_template.is_a?(ERB)
				raise ArgumentError, "Expected ERB but got #{__erb_template.inspect}"
			end
			
			unless __locals.is_a?(Hash)
				raise ArgumentError, "Expected Hash but got #{__locals.inspect}"
			end
			
			unless __mixins.is_a?(Array)
				raise ArgumentError, "Expected Array but got #{__mixins.inspect}"
			end
			
			__mixins.each do |mixin|
				unless mixin.is_a?(Module)
					raise ArgumentError, "Expected Module but got #{mixin.inspect}"
				end
				extend(mixin)
			end
			
			__b = binding
			
			__locals.each_key do |var_name|
				# In the context of the binding (rather than of this block),
				# define the local variables
				eval "#{var_name} = __locals[:#{var_name}]", __b
			end
			
			@result = __erb_template.result(__b)
		end
		
		def self.render(erb_template, locals, mixins = [], &block)
			new(erb_template, locals, mixins, &block).result
		end
		
		attr_reader :result
	end
end