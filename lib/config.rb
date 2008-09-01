# http://www.stephenbartholomew.co.uk/2008/8/22/simple-application-wide-configuration-in-rails

class AppConfig  
	def self.load
		config_file = File.join(RAILS_ROOT, "config", "application.yml")

		if File.exists?(config_file)
			config = YAML.load(File.read(config_file))[RAILS_ENV]

			config.keys.each do |key|
				cattr_accessor key
				send("#{key}=", config[key])
			end
		end
	end
end
