# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def clean(input)
		# XXX change this to a more fine-grained cleanup of the input and then untaint the string
		return h(input)
	end

	# turn linebreaks into paragraphs
	def paragraphize(text)
		return "\n<p>" + h(text).gsub(/(\r?\n)+/, "</p>\n<p>") + "</p>"
	end

	# highlight the text of a search result
	def highlight(text, query)
		return text unless query

		regexp = /(#{Regexp.escape(query)})/i

		text.gsub(regexp, '<span class="highlight">\1</span>').untaint
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
		concat(out || capture(&block), block.binding)
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
		concat(render(options), bind)
	end

	# link to a user using their login
	def user_link(user, *args)
		link_to h(user.login), h(user_path(user.login)), *args
	end

	# display controller-specific sidebar links, if they exist
	# (they're stored in views/[controller]/_side_links.rhtml)
	def controller_side_links
		render_partial 'side_links'
	rescue ActionView::ActionViewError
		# partial was not found, don't add any links
	end

	# turn a distance in km into something human-readable
	def distance km
		"%0.1f km" % km
	end
end
