# coding: utf-8
#
# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
# 
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	# highlight the text of a search result
	def highlight(text, query)
		return text unless query

		regexp = /(#{Regexp.escape(query)})/i

		text.gsub(regexp, '<span class="highlight">\1</span>').html_safe
	end

	# make excerpts for and highlight
	def excerpt_and_highlight(text, query, span=10)
		escaped = Regexp.escape(query)

		regexp = /.*?((\S+ ){0,#{span}}\S*#{escaped}\S*( \S+){0,#{span}}).*/mi

		text.gsub!(regexp, '…\1…' )

		return highlight(text, query)
	end

	def default_content_for(name, &block)
		# used to define source content for view inheritance
		name = name.kind_of?(Symbol) ? ":#{name}" : name
		out = eval("yield #{name}", block.binding)
		out || capture(&block)
	end

	def inheriting_view(options = {}, &block)
		# We accept a shorthand syntax -- if options is a string, render as a file.
		return inheriting_view({:file => options}, &block) if options.is_a?(String)

		bind = options[:binding]

		# Get our differences and additions to the view we're inheriting.
		if block_given?
			bind ||= block.binding
			instance_variable_set(:@content_for_layout, capture(&block))
		end

		raise "Important: inheriting_view() requires a block. " +
			"An empty block (eg, using {}) is suitable." unless bind

		# If we're inheriting a partial, lend our local context to that partial.
		options[:locals] = eval("local_assigns", bind) if options[:partial]

		options[:use_full_path] = true

		# Render our parent view.
		render(options)
	end

	# link to a user using their login
	def user_link(user, *args)
		link_to h(user.login), h(user_path(user.login)), *args
	end

	# display controller-specific sidebar links, if they exist
	# (they're stored in views/[controller]/_side_links.rhtml)
	def controller_side_links
		render :partial => 'side_links'
	rescue ActionView::ActionViewError
		# partial was not found, don't add any links
	end

	# turn a distance in km into something human-readable
	def distance km
		"%0.1f km" % km
	end

	def cover_photo item
		image_tag item.cover_url, :class => 'cover_photo', :alt => ''
	end
end
