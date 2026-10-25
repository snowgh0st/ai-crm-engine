# frozen_string_literal: true

class DocumentsController < ApplicationController
  def create
    @document = Document.new(document_params)
    
    if @document.save
      redirect_to root_path, notice: "Document successfully queued and enriched!"
    else
      redirect_to root_path, alert: "Failed to create document: #{@document.errors.full_messages.join(', ')}"
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :content, :source_type)
  end
end