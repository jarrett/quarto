require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/sample_models')

describe Quarto::ElementWrapper::Children do
	before :each do
		Quarto.xml_source = File.open(SAMPLE_DIR + '/xml/companies.xml')
		@xml = Quarto.xml_doc
	end
	
	context '.children' do
		it 'should create a children accessor' do
			@element = @xml.elements['companies/company']
			@company = Company.new(@element)
			@company.should respond_to(:employees)
			@company.employees.should be_a(Quarto::ElementWrapper::ChildrenProxy)
			@company.employees.length.should == 2 # In the sample XML file, 37Signals has two employees.
			@company.employees.each do |employee|
				employee.should be_a(Employee)
			end
		end
	end
	
	context '.children given :wrapper_class' do
		it 'should use the specified class instead of the default' do
			class CompanyWithWrapperClass < Quarto::ElementWrapper::Base
				element_name = 'company'
				children :employees, :wrapper_class => 'CrazyEmployee'
			end
			
			class CrazyEmployee < Quarto::ElementWrapper::Base; end
			
			@element = @xml.elements['companies/company']
			@company = CompanyWithWrapperClass.new(@element)
			@company.employees.each do |employee|
				employee.should be_a(CrazyEmployee)
			end
			
			Object.class_eval do
				remove_const :CompanyWithWrapperClass
				remove_const :CrazyEmployee
			end
		end
	end
	
	context '.children given :collection_element' do
		it 'should use the specified collection element instead of the default' do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
			@company.should respond_to(:products)
			@company.products.should be_a(Quarto::ElementWrapper::ChildrenProxy)
			@company.products.length.should == 2
			@company.products.each do |product|
				product.should be_a(Product)
			end
		end
	end
	
	context '.children given :collection_element => nil' do
		it 'should create a children accessor that uses immediate children of the element' do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
			@company.should respond_to(:locations)
			@company.locations.should be_a(Quarto::ElementWrapper::ChildrenProxy)
			@company.locations.length.should == 2
			@company.locations.each do |location|
				location.should be_a(Location)
			end
		end
	end
	
	context '.chldren given :element_name' do
		it 'should use the specified element instead of the default' do
			class CompanyWithElementName < Quarto::ElementWrapper::Base
				children :the_employees, :element_name => 'employee'
			end
			
			@element = @xml.elements['companies/company']
			@company = CompanyWithElementName.new(@element)
			@company.the_employees.each do |employee|
				employee.should be_a(Employee)
				employee.element.name.should == 'employee'
			end
			
			Object.class_eval do
				remove_const :CompanyWithElementName
			end
		end
	end
	
	context '.parent for an element in a collection' do
		it 'should create an accessor for the parent object' do
			@element = @xml.elements['companies/company/employees/employee']
			@employee = Employee.new(@element)
			@employee.should respond_to(:company)
			@employee.company.should be_a(Company)
			@employee.company.name.should == '37Signals'
		end
	end
	
	context '.parent for an element that\'s not in a collection' do
		it 'should create an accessor for the parent object' do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
			@location= @company.locations.first
			@location.company.should == @company
		end
	end
	
	context '.parent given :element_name' do
		it 'should test for something' do
			# create classes
			class EmployeeWithElementName < Quarto::ElementWrapper::Base
				parent :the_company, :element_name => 'company'
			end
			
			@element = @xml.elements['//employee']
			@employee = EmployeeWithElementName.new(@element)
			@employee.the_company.should be_a(Company)
			@employee.the_company.element.name.should == 'company'
			
			Object.class_eval do
				remove_const :EmployeeWithElementName
			end
		end
	end
	
	context '.parent given :wrapper_class' do
		it 'should use the specified class instead of the default' do
			class EmployeeWithWrapperClass < Quarto::ElementWrapper::Base
				parent :company, :wrapper_class => 'CrazyCompany'
			end
			
			class CrazyCompany < Quarto::ElementWrapper::Base; end
			
			@element = @xml.elements['//employee']
			@employee = EmployeeWithWrapperClass.new(@element)
			@employee.company.should be_a(CrazyCompany)
			
			Object.class_eval do
				remove_const :EmployeeWithWrapperClass
				remove_const :CrazyCompany
			end
		end
	end
	
	context '.child' do
		before :each do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
		end
		
		it 'should create an accessor that returns the child if it exists' do
			@company.mascot.should be_a(Mascot)
		end
		
		it 'should create an accessor that returns nil if the child does not exist' do
			@company = Company.find :first
			@company.mascot.should == nil
		end
	end
	
	context '.child given :wrapper_class' do
		it 'should use the specified class instead of the default' do
			class CompanyWithWrapperClass < Quarto::ElementWrapper::Base
				child :mascot, :wrapper_class => 'CrazyMascot'
			end
			
			class CrazyMascot < Quarto::ElementWrapper::Base; end
			
			@company = CompanyWithWrapperClass.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
			@company.mascot.should be_a(CrazyMascot)
			
			Object.class_eval do
				remove_const :CompanyWithWrapperClass
				remove_const :CrazyMascot
			end
		end
	end
	
	context '.child given :element_name' do
		it 'should use the specified element name instead of the default' do
			class CompanyWithElementName < Quarto::ElementWrapper::Base
				child :the_mascot, :element_name => 'mascot'
			end
			
			@company = CompanyWithElementName.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
			@company.the_mascot.should be_a(Mascot)
			@company.the_mascot.element.name.should == 'mascot'
			
			Object.class_eval do
				remove_const :CompanyWithElementName
			end
		end
	end
end

describe Quarto::ElementWrapper::ChildrenProxy do
	before :each do
		Quarto.xml_source = File.open(SAMPLE_DIR + '/xml/companies.xml')
		@xml = Quarto.xml_doc
		@element = @xml.elements['companies/company']
		@company = Company.new(@element)
	end
	
	it 'should respond to Enumerable methods' do
		[:collect, :select, :inject, :detect, :include?].each do |meth|
			@company.employees.should respond_to(meth)
		end
	end
	
	it 'should support #first' do
		@company.employees.should respond_to(:first)
		@company.employees.first.should == @company.employees.to_a.first
	end
	
	it 'should support #last' do
		@company.employees.should respond_to(:last)
		@company.employees.last.should == @company.employees.to_a.last
	end
	
	it 'should support #empty?' do
		@company.employees.should respond_to(:empty?)
		@company.employees.empty?.should == false
	end
	
	context '#each' do
		it 'should iterate over each child' do
			expected_names = ['DHH', 'Jamis Buck']
			actual_names = []
			@company.employees.each do |employee|
				actual_names << employee.name
			end
			actual_names.should == expected_names
		end
	end
end