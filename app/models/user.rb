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

require 'taggable'

require 'digest/sha1'
require 'open-uri'

class User < ActiveRecord::Base
	# Virtual attribute for the unencrypted password
	attr_accessor :password

	# don't allow these attributes to be mass-assigned
	attr_protected :login, :created_at, :updated_at, :activated_at, :crypted_password, :salt

	validates_presence_of			:login, :email
	validates_presence_of			:password,									 :if => :password_required?
	validates_presence_of			:password_confirmation,			 :if => :password_required?
	validates_length_of				:password, :within => 4..40, :if => :password_required?
	validates_confirmation_of :password,									 :if => :password_required?
	validates_length_of				:login,		 :within => 3..40
	validates_length_of				:email,		 :within => 3..100
	validates_format_of				:email,		 :with	 => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
	validates_uniqueness_of		:login, :email, :case_sensitive => false

	geocoded_by :postalcode
	before_save :geocode, if: ->(o){ o.postalcode.present? and o.postalcode_changed? }

	before_save :encrypt_password

	before_create :make_activation_code

	belongs_to :region

	has_many :owned,
		:class_name => 'Item',
		:foreign_key => :owner_id,
		:order => 'title'

	# this user's past and present borrowings
	has_many :borrowings, :foreign_key => :borrower_id, :class_name => 'Loan'

	# outstanding loans and loan requests
	has_many :borrowed_and_pending, :foreign_key => :borrower_id,
		:class_name => 'Loan', :conditions => "status NOT IN ('#{I18n.t 'loans.status.returned'}', '#{I18n.t 'loans.status.rejected'}')"

	has_many :lent_and_pending, :class_name => 'Loan', :through => :owned,
		:source => :lendings, :conditions => "status NOT IN ('#{I18n.t 'loans.status.returned'}', '#{I18n.t 'loans.status.rejected'}')"

	# items that this user is currently borrowing
	has_many :borrowed, :class_name => 'Item', :through => :borrowings,
		:source => :item, :conditions => "status = '#{I18n.t 'loans.status.lent'}'"

	has_many :comments, :class_name => 'UserComment'

	# gets all the tags this user has used and how many times they've used them
	# sorted with most occurances first
	def tag_counts
		ItemTagging.count(:conditions => { 'items.owner_id' => self },
											:include => [:thing, :tag],
											:group => 'name',
											:order => 'COUNT(*) DESC')
	end

	# specifically for tagging users
	def self.tagging_class; UserTagging; end
	include Taggable

	def self.find_by_tag tag
		tag = Tag.find_by_name(tag)

		tag ? tag.users : []
	end

	# users are generally displayed with their login
	def to_s; login; end

	# Activates the user in the database.
	def activate
		self.activated_at = Time.now.utc
		self.activation_code = nil
		self.save!
	end

	# Authenticates a user by their login name or email address and unencrypted password.
	# Returns the user or nil.
	def self.authenticate(login, password)
		# hide records with a nil activated_at
		u= where('(login = ? OR email = ?) AND activated_at IS NOT NULL', login, login).first

		if u and u.authenticated?(password)
			u
		end
	end

	# --- password management ---
	# Encrypts the password with the user salt
	def encrypt(password)
		self.class.encrypt(password, salt)
	end

	# "encrypts" some data
	def self.encrypt(x, y)
		Digest::SHA1.hexdigest("--#{y}--#{x}--")
	end

	# replace the user's password with a randomly generated one.
	# the calling function needs to send it to the user somehow.
	def reset_password!
		self.password = pseudorandom_string[1..16]
		self.password_confirmation = self.password

		save!

		UserMailer.password_reset_notification(self, self.password).deliver

		self.password
	end

	def authenticated?(password)
		crypted_password == encrypt(password)
	end

	# before filter called on every save
	def encrypt_password
		return if password.blank?
		if new_record?
			self.salt = self.class.encrypt('login', Time.now)
		end
		self.crypted_password = encrypt(password)
	end

	def remember_token?
		remember_token_expires_at && Time.now.utc < remember_token_expires_at
	end

	# These create and unset the fields required for remembering users between
	# browser closes
	def remember_me
		self.remember_token_expires_at = 2.weeks.from_now.utc
		self.remember_token			   = encrypt("#{email}--#{remember_token_expires_at}")
		save(:validate => false)
	end

	def forget_me
		self.remember_token_expires_at = nil
		self.remember_token			   = nil
		save(:validate => false)
	end

	# --- geolocation stuff ---

	# average great-circle radius according to Wikipedia
	EARTH_RADIUS = 6372.795

	# the distance between this user and another, in kilometres
	#
	# calculated using the haversine formula
	# <http://en.wikipedia.org/wiki/Haversine_formula>
	def distance_from other
		la1 = self.latitude * Math::PI / 180
		lo1 = self.longitude * Math::PI / 180

		la2 = other.latitude * Math::PI / 180
		lo2 = other.longitude * Math::PI / 180

		d_l = (lo1 - lo2).abs

		EARTH_RADIUS * 2 * Math.asin(Math.sqrt(
			hav(la2-la1) + Math.cos(la1)*Math.cos(la2)*hav(d_l)
		))
	end

	# the haversine function.
	# trig is boring.
	def hav angle
		Math.sin(angle/2.0) ** 2
	end

	def cellphone= cellphone
		cellphone.gsub! /[^\d]/, ''
		super cellphone
	end

	protected
		def password_required?
			crypted_password.blank? || !password.blank?
		end

		def make_activation_code
			self.activation_code = pseudorandom_string
		end

		# this is a pretty wacky method, I think i like it
		def pseudorandom_string
			Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
		end
end
