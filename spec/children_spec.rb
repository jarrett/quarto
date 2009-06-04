require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/sample_project/models/company')
require File.expand_path(File.dirname(__FILE__) + '/sample_project/models/employee')

describe Quarto::ElementWrapperChildren do
	before :each do
		Quarto.xml_source = File.open(SAMPLE_DIR + '/xml/companies.xml')
		@xml = Quarto.xml_doc
	end
	
	context 'an ElementWrapper instance with children' do
		before :each do
			@element = @xml.elements['companies/company']
			@company = Company.new(@element)
		end
		
		it 'should know its children' do
			@company.should respond_to(:employees)
			@company.employees.should be_a(Quarto::Children)
			@company.employees.length.should == 2 # In the sample XML file, 37Signals has two employees.
			@company.employees.each do |employee|
				employee.should be_a(Employee)
			end
		end
	end
	
	context 'an ElementWrapper instance with a parent' do
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
end

describe Quarto::Children do
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