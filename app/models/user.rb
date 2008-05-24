require 'digest/sha1'
require 'open-uri.rb'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  # don't allow these attributes to be mass-assigned
  attr_protected :login, :created_at, :updated_at, :activated_at, :crypted_password, :salt

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_format_of       :email,    :with   => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  before_save :encrypt_password
  before_save :do_geocoding

  before_create :make_activation_code

  belongs_to :region

  has_many :owned, :class_name => 'Item', :foreign_key => :owner_id

  # this user's past and present borrowings
  has_many :borrowings, :foreign_key => :borrower_id, :class_name => 'Loan'

  # items that this user is currently borrowing
  has_many :borrowed, :class_name => 'Item', :through => :borrowings, :source => :item, :conditions => "status = 'lent'"

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # hide records with a nil activated_at
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u && u.authenticated?(password) ? u : nil
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save!
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

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

  # the haversine function
  def hav angle
    Math.sin(angle/2.0) ** 2
  end

  protected
    # turn a postal code into latitude and longitude
    def do_geocoding
      self.latitude = 0
      self.longitude = 0

      googleKey = "ABQIAAAAtMckXwUuUit3GcU7fqrjfhQ-fLx3XxcGMYuMv93Lb2-UXt48NxQJ0Yah9JBOEjCrA8dHFLPTAfhB3w"
      url = "http://maps.google.com/maps/geo?q=#{URI.escape self.postalcode}&output=csv&key=#{googleKey}"

      open(url) { |f|
        f.each_line { |line|
          csv = line.split(',')
          self.latitude = csv[2]
          self.longitude = csv[3]
        }
      }
    end

    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    # If you're going to use activation, uncomment this too
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
end
