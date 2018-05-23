class User < ApplicationRecord
  has_secure_password

  validates_presence_of :email, :first_name, :last_name
  validates_uniqueness_of :email

  before_save :hash_email, :downcase_email

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(email.downcase.strip)
  end

  def downcase_email
    self.email = email.downcase
  end

  def formatted_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end
end
