class Company < Quarto::ElementWrapper
	element_attrs :name, :industry
	
	children :employees
	
	def competitors
		@competitors ||= self.class.find(:all, :xpath => "companies/company[industry='#{@industry}' and name!='#{@name}']")
	end
end