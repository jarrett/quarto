class Location < Quarto::ElementWrapper::Base
	parent :company
	
	element_attrs 'name', 'location'
end