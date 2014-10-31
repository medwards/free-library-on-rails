module LayoutsHelper
	def navitab(text, url, active)
		klass = active ? 'activenavitab' : 'navitab'
		link_to(text, url, :class => klass) + content_tag(:span, ' | ', class: 'hide')
	end

	def page_title
		page_title = AppConfig.site_name.untaint
		page_title += " - #{h @title}" if @title
		page_title
	end
end
