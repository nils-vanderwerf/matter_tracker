class DashboardController < ApplicationController
  def index
    @open_count    = Matter.open.count
    @pending_count = Matter.pending.count
    @closed_count  = Matter.closed.count

    @overdue_matters  = Matter.overdue.order(:due_date).includes(:client)
    @upcoming_matters = Matter.where.not(status: "Closed")
                              .where(due_date: Date.today..14.days.from_now)
                              .order(:due_date)
                              .includes(:client)

    @overdue_task_count  = Task.overdue.count

    @high_priority_tasks = Task.where(priority: "High")
                               .where.not(status: "Completed")
                               .order(:due_date)
                               .includes(matter: :client)
  end
end
