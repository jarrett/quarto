module Quarto
	class Binder
		# Return a new Binding object where the only defined
		# local variables are those specified in the hash +locals+
		def self.get_binding(locals, &block)
			new(locals).get_binding(&block)
		end
		
		def get_binding
			b = binding
			@locals.each do |var_name, value|
				eval "#{var_name} = @locals[:#{var_name}]", b
			end
			b
		end
		
		def initialize(locals)
			@locals = locals.inject({}) do |result, (var_name, value)|
				result[var_name.to_sym] = value
				result
			end
		end
	end
end