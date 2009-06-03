module Quarto
	@config = {}
	
	def self.config(configs_to_merge = nil)
		if configs_to_merge.is_a?(Hash)
			@config.merge!(configs_to_merge)
		end
		@config
	end
end