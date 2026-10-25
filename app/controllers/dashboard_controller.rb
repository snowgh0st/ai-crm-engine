# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @documents = Document.order(created_at: :desc).limit(10)
    
    if params[:query].present?
      query_vector = EmbeddingGenerator.call(params[:query])
      @search_results = Document.nearest_neighbors(:embedding, query_vector, distance: 'cosine').limit(5)
    end
  end
end