module LayoutsHelper
	def navitab(text, url, active)
		klass = active ? 'activenavitab' : 'navitab'
		link_to(text, url, :class => klass) + '<span class="hide"> | </span>'.html_safe
	end
end
