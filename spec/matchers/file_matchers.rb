module Quarto
	module FileMatchers
		class ExistOnDisk
			def matches?(target)
				@target = File.expand_path(target)
				File.exists?(@target)
			end
			
			def failure_message
				"Expected file #{@target} to exist"
			end
			
			def negative_failure_message
				"Expected file #{@target} not to exist"
			end
		end
		
		def exist_on_disk
			ExistOnDisk.new
		end
	end
end