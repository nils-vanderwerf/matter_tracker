class Note < ApplicationRecord
  belongs_to :matter

  validates :body, presence: true
end
