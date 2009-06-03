module Quarto
	def self.xml_source=(source)
		raise ArgumentError, "Expected File but got #{source.inspect}" unless source.is_a?(File)
		@xml_doc = REXML::Document.new(source)
	end
	
	def self.xml_doc
		@xml_doc
	end
end