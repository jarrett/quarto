class Employee < Quarto::ElementWrapper::Base
	include Quarto::UrlHelper
	
	element_attrs :name
	
	parent :company
	
	def self.from_element(el)
		employee = new(el)
		employee.ivs_from_elements('name')
	end
	
	def to_path
		'employees/' + urlize(name) + '.html'
	end
end