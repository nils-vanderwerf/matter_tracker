class Matter < ApplicationRecord
  MATTER_TYPES = ["Family Law", "Criminal", "Conveyancing", "Commercial"].freeze
  STATUSES = ["Open", "Pending", "Closed"].freeze

  belongs_to :client, optional: true
  has_many :tasks, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :status_changes, class_name: "MatterStatusChange", dependent: :destroy

  after_create :record_initial_status
  after_update :record_status_change, if: :saved_change_to_status?

  validates :title, presence: true
  validates :matter_type, inclusion: { in: MATTER_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validate :due_date_not_in_past, on: :create

  def close
    return false if closed?
    update(status: "Closed")
  end

  def reopen
    return false unless closed?
    update(status: "Open")
  end

  def closed?
    status == "Closed"
  end

  private

  def record_initial_status
    status_changes.create!(status: status)
  end

  def record_status_change
    status_changes.create!(status: status)
  end

  def due_date_not_in_past
    return if due_date.blank?
    errors.add(:due_date, "must be today or in the future") if due_date < Date.today
  end

  scope :open, -> { where(status: "Open") }
  scope :pending, -> { where(status: "Pending") }
  scope :closed, -> { where(status: "Closed") }
  scope :overdue, -> { where.not(status: "Closed").where("due_date < ?", Date.today) }
  scope :by_due_date, -> { order(:due_date) }
end
