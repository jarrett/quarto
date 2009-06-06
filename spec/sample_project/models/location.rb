class Location < Quarto::ElementWrapper::Base
	parent :company
	
	element_attrs 'city', 'state'
end