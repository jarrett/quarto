class Employee < Quarto::ElementWrapper
	def self.from_element(el)
		employee = new(el)
		employee.ivs_from_elements('name')
	end
end