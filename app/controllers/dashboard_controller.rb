class DashboardController < ApplicationController
  MATTER_SORT_COLUMNS = {
    "title"       => "matters.title",
    "client"      => "clients.name",
    "matter_type" => "matters.matter_type",
    "status"      => "matters.status",
    "due_date"    => "matters.due_date"
  }.freeze

  TASK_SORT_COLUMNS = {
    "title"    => "tasks.title",
    "matter"   => "matters.title",
    "client"   => "clients.name",
    "status"   => "tasks.status",
    "due_date" => "tasks.due_date"
  }.freeze

  def index
    @matter_type_filter = params[:matter_type].presence
    @task_status_filter = params[:task_status].presence

    @matters_sort = MATTER_SORT_COLUMNS.key?(params[:matters_sort]) ? params[:matters_sort] : "due_date"
    @matters_dir  = params[:matters_dir] == "desc" ? "desc" : "asc"
    @tasks_sort   = TASK_SORT_COLUMNS.key?(params[:tasks_sort])   ? params[:tasks_sort]   : "due_date"
    @tasks_dir    = params[:tasks_dir] == "desc" ? "desc" : "asc"

    matter_order = Arel.sql("#{MATTER_SORT_COLUMNS[@matters_sort]} #{@matters_dir}")
    task_order   = Arel.sql("#{TASK_SORT_COLUMNS[@tasks_sort]} #{@tasks_dir}")

    # Stat cards are always global
    @open_count         = Matter.open.count
    @pending_count      = Matter.pending.count
    @closed_count       = Matter.closed.count
    @overdue_task_count = Task.overdue.count

    matter_scope = @matter_type_filter ? Matter.where(matter_type: @matter_type_filter) : Matter.all
    matter_scope = @matters_sort == "client" ? matter_scope.eager_load(:client) : matter_scope.includes(:client)

    @overdue_matters  = matter_scope.overdue.order(matter_order)
    @upcoming_matters = matter_scope.where.not(status: "Closed")
                                    .where(due_date: Date.today..14.days.from_now)
                                    .order(matter_order)

    task_scope = Task.where(priority: "High").where.not(status: "Completed")
    task_scope = task_scope.where(status: @task_status_filter) if @task_status_filter
    task_scope = case @tasks_sort
                 when "matter" then task_scope.joins(:matter).includes(matter: :client)
                 when "client" then task_scope.joins(matter: :client).includes(matter: :client)
                 else               task_scope.includes(matter: :client)
                 end
    @high_priority_tasks = task_scope.order(task_order)
  end
end
