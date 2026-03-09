class Matter < ApplicationRecord
  MATTER_TYPES = ["Family Law", "Criminal", "Conveyancing", "Commercial"].freeze
  STATUSES = ["Open", "Pending", "Closed"].freeze

  belongs_to :client, optional: true
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :matter_type, inclusion: { in: MATTER_TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :open, -> { where(status: "Open") }
  scope :pending, -> { where(status: "Pending") }
  scope :closed, -> { where(status: "Closed") }
  scope :by_due_date, -> { order(:due_date) }
end
