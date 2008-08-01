# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '80917b8faf645ce57e19ede4fec57e60'

  layout 'base'

  # use acts_as_authenticated bits
  include AuthenticatedSystem

  # Not Found
  def four_oh_four
    render :file => './public/404.html', :status => 404
  end

  # throw up a raw 401 Unauthorized
  #
  # you may want to redirect instead of using this
  def unauthorized reason
    render :file => './public/422.html', :status => 401
  end

  # determine the name of the region that we're operating in
  def region
    return @region if @region

    name = if ENV['RAILS_ENV'] == 'development'
             # hardcoded region for development
             'edmonton'
           else
             # the first part of the domain name
             @request.host.split(/\./).first
           end

    @region = Region.find_by_subdomain(name)
  end

  # like redirect_to :back, but gives a default in case Referer isn't set
  def redirect_back_or_to(default)
    redirect :back
  rescue ActionController::RedirectBackError
    redirect_to default
  end
end
