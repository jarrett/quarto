module Quarto
	module TransformationHelper
		# Tranforms the children of +element+ using
		# an instance of +transformer_class+ and returns
		# a string representation of the result.
		#
		# +transformer_class+ must be a subclass of
		# Quarto::Transformer or <tt>nil</tt>. If it's
		# <tt>nil</tt> (which is the default), the default
		# subclass will be used. The default subclass is set
		# in <tt>generate.rb</tt> as follows:
		#
		#   config(:default_transformer_class, YourSubclass)
		#
		# If you do not specify a default class,
		# <tt>HtmlTransformer</tt> will be used.
		def transform_xml(element, transformer_class = Quarto::HtmlTransformer)
			raise ArgumentError, "Expected REXML::Element but got #{element.inspect}" unless element.is_a?(REXML::Element)
			class_error = "Expected subclass of Tranformer but got #{transformer_class.inspect}"
			raise ArgumentError, class_error unless transformer_class.is_a?(Class)
			klass = transformer_class
			while klass != Quarto::Transformer and klass != Object
				klass = klass.superclass
			end
			raise ArgumentError, class_error unless Quarto::Transformer == klass
			transformer_class.new.transform(element)
		end
	end
end