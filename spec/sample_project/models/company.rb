class Company < Quarto::ElementWrapper::Base
	element_attrs :name, :industry
	
	children :employees
	
	children :products, :collection_element => 'selling'
	
	children :locations, :collection_element => nil
	
	child :mascot
	
	def competitors
		@competitors ||= self.class.find(:all, :xpath => "companies/company[industry='#{industry}' and name!='#{name}']")
	end
end