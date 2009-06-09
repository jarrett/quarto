Quarto.generate do
	config(:site_root, '') # This determines how abs_url works. If you need your absolute URLs to be prepended with something, you can put it here.

	use_xml('companies.xml')

	render 'companies.html.erb', '', 'companies.html', :companies => Company.find(:all)

	Employee.find(:all).each do |employee|
		render 'employee.html.erb', 'employees', "#{urlize(employee.name)}.html", :employee => employee
	end
end