class User < ApplicationRecord
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :social_users
  has_many :socials, through: :social_users
  has_many :emails
  has_many :breaks
  has_many :statuses

  has_and_belongs_to_many :contacts, class_name: 'User',
                                     join_table: 'contacts',
                                     foreign_key: 'from_user',
                                     association_foreign_key: 'to_user'

  has_many :default_locations
  has_many :meeting_participations
  has_many :constraints

  def primary_email
    Email.find(primary_email_id)
  end

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  validates :name, :surname, :nickname, :password, :preference_list, presence: true
  validates :nickname, :primary_email_id, uniqueness: true

  validate :primary_email_in_emails

  has_secure_password

  def get_last_default_location_before(current_day)
    list_default_location = []
    default_locations.each do |dl|
      if dl.day_of_the_week < current_day.wday || ((dl.day_of_the_week == current_day.wday) && (dl.starting_hour <= (current_day.hour * 60 + current_day.min)))
        list_default_location.push dl
      end
    end
    list_default_location = list_default_location.sort_by { |dl1| [(dl1.day_of_the_week * 60 * 24 + dl1.starting_hour)] }

    if list_default_location.blank?
      return get_last_default_location_before(DateTime.parse('December 9th 2017 11:59:59 PM')) # to take the last default location of the week, infinite loop if user doesn't have any def location
    else
      return list_default_location.last
    end
  end

  def get_first_location_after(current_day)
    # ATTENTION IT RETURNS THE FIRST DEFAULT LOCATION THAT STARTS AFTER current_day. if you want the current one use the get_last_default_location_before method
    list_default_location = []
    default_locations.each do |dl|
      if dl.day_of_the_week > current_day.wday || (dl.day_of_the_week == current_day.wday && dl.starting_hour >= (current_day.hour * 24 + current_day.min))
        list_default_location.push dl
      end
    end
    list_default_location = list_default_location.sort_by { |dl1| [(dl1.day_of_the_week * 3600 + dl1.starting_hour)] }
    list_default_location.first
  end

  private

  def primary_email_in_emails
    return if primary_email_id.blank?
  end
end
