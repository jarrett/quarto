module Quarto
	class Rendering # :nodoc: all
		include UrlHelper
		
		def initialize(__erb_template, __locals)
			__b = binding
			__locals.each_key do |var_name|
				# In the context of this method (rather than of this block),
				# define the local variables
				eval "#{var_name} = __locals[:#{var_name}]", __b
			end
			
			@result = __erb_template.result(__b)
		end
		
		def self.render(erb_template, locals, &block)
			new(erb_template, locals, &block).result
		end
		
		attr_reader :result
	end
end