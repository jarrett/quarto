module Quarto
	PROJECT_SUBFOLDERS = [
		'layouts',
		'models',
		'output',
		'pages',
		'xml'
	]

	STARTER_GENERATE_FILE = %q(
Quarto.generate do
	# Your code here
	# e.g.:
	# render 'companies.html.erb', '', 'companies.html', :companies => Company.find(:all)
end
)
	
	def self.init_project(project_path)
		raise ArgumentError, "Expected string, but got #{project_path.inspect}" unless project_path.is_a?(String) and !project_path.empty?
		project_path = File.expand_path(project_path)
		unless File.exists?(project_path)
			Dir.mkdir project_path
		end
		PROJECT_SUBFOLDERS.each do |subfolder|
			subfolder = project_path + '/' + subfolder
			unless File.exists?(subfolder)
				Dir.mkdir subfolder
			end
		end
		generate_file = project_path + '/generate.rb'
		unless File.exists?(generate_file)
			File.open(generate_file, 'w') do |file|
				file.print(STARTER_GENERATE_FILE)
			end
		end
		true
	end
end