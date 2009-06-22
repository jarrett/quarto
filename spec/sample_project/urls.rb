module Quarto
	module ProjectUrls
		include Quarto::UrlHelper
		
		def companies_url
			relative_path('companies.html')
		end
	end
end