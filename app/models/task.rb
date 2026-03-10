class Task < ApplicationRecord
  STATUSES = ["Pending", "In Progress", "Completed"].freeze
  PRIORITIES = ["Low", "Medium", "High"].freeze

  belongs_to :matter

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  scope :pending, -> { where(status: "Pending") }
  scope :in_progress, -> { where(status: "In Progress") }
  scope :completed, -> { where(status: "Completed") }
  scope :by_due_date, -> { order(:due_date) }
  scope :high_priority, -> { where(priority: "High") }
  scope :overdue, -> { where.not(status: "Completed").where("due_date < ?", Date.today) }
end
