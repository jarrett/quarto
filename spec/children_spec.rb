require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::Children do
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