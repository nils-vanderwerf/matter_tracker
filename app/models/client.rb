class Client < ApplicationRecord
  has_many :matters, dependent: :nullify

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :alphabetical, -> { order(:name) }
end
