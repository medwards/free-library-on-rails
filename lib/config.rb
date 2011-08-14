# http://www.stephenbartholomew.co.uk/2008/8/22/simple-application-wide-configuration-in-rails

class AppConfig
	def self.load
		config_file = File.join(Rails.root.to_s, "config", "application.yml")

		if File.exists?(config_file)
			config = YAML.load(File.read(config_file))[Rails.env]

			config.keys.each do |key|
				cattr_accessor key
				send("#{key}=", config[key])
			end
		end
	end
end
