module Quarto
	def self.xml_source=(source) # :nodoc:
		raise ArgumentError, "Expected File but got #{source.inspect}" unless source.is_a?(File)
		@xml_doc = REXML::Document.new(source)
	end
	
	def self.xml_doc # :nodoc:
		@xml_doc
	end
end