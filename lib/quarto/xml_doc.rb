module Quarto
	def self.xml_source=(source)
		@xml_doc = REXML::Document.new(source)
	end
	
	def self.xml_doc
		@xml_doc
	end
end