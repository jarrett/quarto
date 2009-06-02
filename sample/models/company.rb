class Company < Quarto::ElementWrapper
	attr_reader :name, :industry
	
	def self.from_element(el)
		company = new(el)
		company.ivs_from_elements('name', 'industry')
	end
	
	def competitors
		self.class.find(:all, :xpath => "companies/company[industry='#{@industry}' and name!='#{@name}']")
	end
end