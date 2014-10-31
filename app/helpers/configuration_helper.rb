module ConfigurationHelper
	def site_name(**options)
		if options[:short]
			AppConfig.site_name_short || AppConfig.site_name
		else
			AppConfig.site_name
		end.untaint
	end

	def site_region(**options)
		if options[:long]
			AppConfig.site_region_long || AppConfig.site_region
		else
			AppConfig.site_region
		end
	end
end
