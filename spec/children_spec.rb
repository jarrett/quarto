require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/sample_models')

describe Quarto::ElementWrapper::Children do
	before :each do
		Quarto.xml_source = File.open(SAMPLE_DIR + '/xml/companies.xml')
		@xml = Quarto.xml_doc
	end
	
	context 'an ElementWrapper::Base instance with children' do
		before :each do
			@element = @xml.elements['companies/company']
			@company = Company.new(@element)
		end
		
		it 'should know its children' do
			@company.should respond_to(:employees)
			@company.employees.should be_a(Quarto::ElementWrapper::ChildrenProxy)
			@company.employees.length.should == 2 # In the sample XML file, 37Signals has two employees.
			@company.employees.each do |employee|
				employee.should be_a(Employee)
			end
		end
	end
	
	context '.children given :wrapper_class' do
		before :all do
			class CompanyWithWrapperClass < Quarto::ElementWrapper::Base
				element_name = 'company'
				children :employees, :wrapper_class => 'CrazyEmployee'
			end
			
			class CrazyEmployee < Quarto::ElementWrapper::Base; end
		end
		
		before :each do
			@element = @xml.elements['companies/company']
			@company = CompanyWithWrapperClass.new(@element)
		end
		
		after :all do
			Object.class_eval do
				remove_const :CompanyWithWrapperClass
				remove_const :CrazyEmployee
			end
		end
		
		it 'should use the specified class instead of the default' do
			@company.employees.each do |employee|
				employee.should be_a(CrazyEmployee)
			end
		end
	end
	
	context '.children given :collection_element' do
		before :each do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
		end
		
		it 'should know its children' do
			@company.should respond_to(:products)
			@company.products.should be_a(Quarto::ElementWrapper::ChildrenProxy)
			@company.products.length.should == 2
			@company.products.each do |product|
				product.should be_a(Product)
			end
		end
	end
	
	context '.children given :collection_element => nil' do
		before :each do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
		end
		
		it 'should know its children' do
			@company.should respond_to(:locations)
			@company.locations.should be_a(Quarto::ElementWrapper::ChildrenProxy)
			@company.locations.length.should == 2
			@company.locations.each do |location|
				location.should be_a(Location)
			end
		end
	end
	
	context '#parent' do
		before :each do
			@element = @xml.elements['companies/company/employees/employee']
			@employee = Employee.new(@element)
		end
		
		it 'should have children which know their parent' do
			@employee.should respond_to(:company)
			@employee.company.should be_a(Company)
			@employee.company.name.should == '37Signals'
		end
	end
	
	context '.child' do
		before :each do
			@company = Company.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
		end
		
		it 'should know its child' do
			@company.mascot.should be_a(Mascot)
		end
		
		it 'should make an accessor that returns nil if the child does not exist' do
			@company = Company.find :first
			@company.mascot.should == nil
		end
	end
	
	context '.child given :wrapper_class' do
		before :all do
			class CompanyWithWrapperClass < Quarto::ElementWrapper::Base
				child :mascot, :wrapper_class => 'CrazyMascot'
			end
			
			class CrazyMascot < Quarto::ElementWrapper::Base; end
		end
		
		after :all do
			Object.class_eval do
				remove_const :CompanyWithWrapperClass
				remove_const :CrazyMascot
			end
		end
		
		before :each do
			@company = CompanyWithWrapperClass.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
		end
		
		it 'should use the specified class instead of the default' do
			@company.mascot.should be_a(CrazyMascot)
		end
	end
	
	context '.child given :element_name' do
		before :all do
			class CompanyWithElementName < Quarto::ElementWrapper::Base
				child :the_mascot, :element_name => 'mascot'
			end
		end
		
		after :all do
			Object.class_eval do
				remove_const :CompanyWithElementName
			end
		end
		
		before :each do
			@company = CompanyWithElementName.find(:first, :xpath => "//company[name='Mega-lo-Mart']")
		end
		
		it 'should use the specified element name instead of the default' do
			@company.the_mascot.should be_a(Mascot)
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
	
	it 'should support empty?' do
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