class TasksController < ApplicationController
  before_action :set_matter, only: [:new, :create]
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @task = @matter.tasks.new
  end

  def create
    @task = @matter.tasks.new(task_params)
    if @task.save
      redirect_to @task.matter, notice: "Task created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @matter = @task.matter
  end

  def update
    if @task.update(task_params)
      redirect_to @task.matter, notice: "Task updated successfully."
    else
      @matter = @task.matter
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    matter = @task.matter
    @task.destroy
    redirect_to matter, notice: "Task deleted."
  end

  private

  def set_matter
    @matter = Matter.find(params[:matter_id])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :status, :priority)
  end
end
