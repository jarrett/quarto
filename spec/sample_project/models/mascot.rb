class Mascot < Quarto::ElementWrapper::Base
	parent :company
	
	element_attrs 'name'
end