class DescriptionsTransformer < Quarto::HtmlTransformer
	def transform_tv(element, raise_on_unrecognized_elements)
		replace_element(element, 'cite', raise_on_unrecognized_elements, 'class' => 'tv_show')
	end
end