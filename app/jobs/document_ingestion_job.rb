# frozen_string_literal: true

class DocumentIngestionJob < ApplicationJob
  queue_as :default

  # =========================================================================
  # PATH MAPPING:
  # - Hot Path: Asynchronously creating document records and generating embeddings.
  # - Execution Path: Executing Document.create! inside a background worker.
  # - Sad Path: Handling OpenAI rate limits or database connection drops with retries.
  # =========================================================================

  sidekiq_options retry: 3

  def perform(attributes)
    # Execution Path: Create document record, triggering our EmbeddingGenerator callback
    document = Document.create!(attributes)
    Rails.logger.info("Successfully ingested document ID #{document.id} asynchronously via Sidekiq.")
  rescue StandardError => e
    # Sad Path: Log error and let Sidekiq handle retry backoff
    Rails.logger.error("DocumentIngestionJob failed for attributes: #{attributes.inspect}. Error: #{e.message}")
    raise e
  end
end