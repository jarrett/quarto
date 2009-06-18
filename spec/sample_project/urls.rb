module Quarto
	module ProjectUrls
		include Quarto::UrlHelper
		
		def companies_url
			abs_path('companies.html')
		end
	end
end