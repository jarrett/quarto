#Quarto.config(:site_root => 'http://localhost/')

use_xml('companies.xml')

render 'companies.html.erb', '', 'companies.html', :companies => Company.find(:all)

Employee.find(:all).each do |employee|
	render 'employee.html.erb', 'employees', "#{urlize(employee.name)}.html", :employee => employee
end