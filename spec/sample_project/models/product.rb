class Product < Quarto::ElementWrapper::Base
	parent :company
	
	text_attr :name
end