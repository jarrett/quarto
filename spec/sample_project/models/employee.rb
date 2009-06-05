class Employee < Quarto::ElementWrapper::Base
	element_attrs :name
	
	parent :company
	
	def self.from_element(el)
		employee = new(el)
		employee.ivs_from_elements('name')
	end
end