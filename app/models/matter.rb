class Matter < ApplicationRecord
  MATTER_TYPES = ["Family Law", "Criminal", "Conveyancing", "Commercial"].freeze
  STATUSES = ["Open", "Pending", "Closed"].freeze

  belongs_to :client, optional: true
  has_many :tasks, dependent: :destroy
  has_many :notes

  validates :title, presence: true
  validates :matter_type, inclusion: { in: MATTER_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validate :due_date_not_in_past, on: :create

  private

  def due_date_not_in_past
    return if due_date.blank?
    errors.add(:due_date, "must be today or in the future") if due_date < Date.today
  end

  public

  scope :open, -> { where(status: "Open") }
  scope :pending, -> { where(status: "Pending") }
  scope :closed, -> { where(status: "Closed") }
  scope :by_due_date, -> { order(:due_date) }
end
