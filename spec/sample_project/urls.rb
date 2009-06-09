module Quarto
	module ProjectUrls
		include Quarto::UrlHelper
		
		def companies_url
			abs_url('companies.html')
		end
	end
end