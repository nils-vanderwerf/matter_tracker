require "test_helper"

class MatterTest < ActiveSupport::TestCase
  def valid_attributes
    {
      title: "Test Matter",
      matter_type: "Commercial",
      status: "Open"
    }
  end

  # due_date on create
  test "is valid with a due date today" do
    matter = Matter.new(valid_attributes.merge(due_date: Date.today))
    assert matter.valid?
  end

  test "is valid with a due date in the future" do
    matter = Matter.new(valid_attributes.merge(due_date: Date.today + 30))
    assert matter.valid?
  end

  test "is invalid with a due date in the past on create" do
    matter = Matter.new(valid_attributes.merge(due_date: Date.today - 1))
    assert_not matter.valid?
    assert_includes matter.errors[:due_date], "must be today or in the future"
  end

  test "is valid with no due date" do
    matter = Matter.new(valid_attributes.merge(due_date: nil))
    assert matter.valid?
  end

  test "allows a past due date when updating an existing record" do
    matter = Matter.create!(valid_attributes.merge(due_date: Date.today + 1))
    matter.due_date = Date.today - 5
    assert matter.valid?
  end
end
