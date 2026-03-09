class NotesController < ApplicationController
  before_action :set_matter, only: [:create]
  before_action :set_note, only: [:destroy, :edit, :update]

  def create
     @note = @matter.notes.build(note_params)
     if @note.save
      redirect_to @matter, notice: "Note created successfully."
    else
      redirect_to @matter, alert: "Note can't be blank."
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to @note.matter, notice: "Note updated successfully."
    else
      render :edit, status: :unprocessable_entity, alert: "Note can't be blank."
    end
  end

  def destroy
    matter = @note.matter
    @note.destroy
    redirect_to matter, notice: "Note deleted."
  end

  private

  def set_matter
    @matter = Matter.find(params[:matter_id])
  end

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:body)
  end
end