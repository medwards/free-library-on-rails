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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# I think maybe these shouldn't be here?
# Still not clear on how Rails 3 loads libraries.
require 'authenticated_system'
require 'taggable'

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery # :secret => '80917b8faf645ce57e19ede4fec57e60'

	layout 'base'

	# use acts_as_authenticated bits
	include AuthenticatedSystem

	# Not Found
	# You need to return after doing this.
	def four_oh_four
		render :file => './public/404.html', :status => 404
	end

	# throw up a raw 401 Unauthorized.
	# You need to return after doing this.
	#
	# you may want to redirect instead of using this
	def unauthorized reason
		render :file => './public/422.html', :status => 401
	end

	# determine the name of the region that we're operating in
	def region
		return @region if @region

		name = 'edmonton'

		@region = Region.find_by_subdomain(name)
	end

	# like redirect_to :back, but gives a default in case Referer isn't set
	def redirect_back_or_to(default)
		redirect_to :back
	rescue ActionController::RedirectBackError
		redirect_to default
	end
end
