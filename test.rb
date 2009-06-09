require 'erb'

module Foo
	def foo
		6
	end
end

template = ERB.new %q(
The value of x is <%= x %>
The method foo returns <%= foo %>
)
x = 42

b = binding

eval 'include Foo', b

template.extend(Foo)
puts template.result(b)