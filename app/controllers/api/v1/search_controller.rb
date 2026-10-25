# frozen_string_literal: true

module Api
  module V1
    class SearchController < ApplicationController
      # =========================================================================
      # PATH MAPPING:
      # - Hot Path: Successful semantic search returning top matching documents.
      # - Execution Path: Generating query embedding via OpenAI and querying pgvector.
      # - Sad Path: Handling missing query parameters or API failure exceptions.
      # =========================================================================

      def create
        query_text = params[:query]

        # Sad Path: Validate that query text is present
        if query_text.blank?
          return render json: { error: "Query parameter 'query' is required" }, status: :bad_request
        end

        # Execution Path: Generate vector embedding for the search query
        query_vector = EmbeddingGenerator.call(query_text)

        # Hot Path: Perform HNSW approximate nearest neighbor search using cosine distance
        # Limit results to top 5 matches for crisp relevance
        documents = Document.nearest_neighbors(:embedding, query_vector, distance: 'cosine').limit(5)

        # Render successful JSON response including similarity scores
        render json: documents.map { |doc|
          {
            id: doc.id,
            title: doc.title,
            content: doc.content,
            source_type: doc.source_type,
            metadata: doc.metadata,
            similarity_score: (1.0 - doc.neighbor_distance).round(4) # Convert distance to similarity score
          }
        }, status: :ok

      rescue StandardError => e
        # Sad Path: Log error and return clean server error response
        Rails.logger.error("SearchController failed: #{e.message}")
        render json: { error: "Internal server error during vector search" }, status: :internal_server_error
      end
    end
  end
end