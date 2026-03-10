class MattersController < ApplicationController
  before_action :set_client, only: [:new, :create]
  before_action :set_matter, only: [:show, :edit, :update, :destroy, :close, :reopen]

  def show
    @tasks = @matter.tasks.by_due_date
    @client = @matter.client
    @last_status_change = @matter.status_changes.order(created_at: :asc).last
  end

  def new
    @matter = @client.matters.new
  end

  def create
    @matter = @client.matters.new(matter_params)
    if @matter.save
      redirect_to @matter, notice: "Matter created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @client = @matter.client
  end

  def update
    if @matter.update(matter_params)
      redirect_to @matter, notice: "Matter updated successfully."
    else
      @client = @matter.client
      render :edit, status: :unprocessable_entity
    end
  end

  def close
    if @matter.close
      redirect_to @matter, notice: "Matter closed."
    else
      redirect_to @matter, alert: "Matter is already closed."
    end
  end

  def reopen
    if @matter.reopen
      redirect_to @matter, notice: "Matter reopened."
    else
      redirect_to @matter, alert: "Matter is not closed."
    end
  end

  def destroy
    client = @matter.client
    @matter.destroy
    redirect_to client_url(client), notice: "Matter deleted."
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_matter
    @matter = Matter.find(params[:id])
  end

  def matter_params
    params.require(:matter).permit(:title, :matter_type, :status, :due_date, :description)
  end
end
