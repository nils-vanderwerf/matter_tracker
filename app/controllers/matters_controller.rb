class MattersController < ApplicationController
  before_action :set_client, only: [:new, :create]
  before_action :set_matter, only: [:show, :edit, :update, :destroy]

  def show
    @tasks = @matter.tasks.by_due_date
    @client = @matter.client
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
