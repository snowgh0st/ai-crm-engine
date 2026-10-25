# frozen_string_literal: true

class CrmEnrichmentJob < ApplicationJob
  queue_as :default

  # =========================================================================
  # PATH MAPPING:
  # - Hot Path: Successfully finding document and running CrmEnrichmentService.
  # - Execution Path: Executing AI enrichment worker asynchronously via Sidekiq.
  # - Sad Path: Handling missing records or API timeouts with retries.
  # =========================================================================

  sidekiq_options retry: 3

  def perform(document_id)
    document = Document.find_by(id: document_id)
    
    # Sad Path: Exit gracefully if document was deleted before job ran
    unless document
      Rails.logger.warn("CrmEnrichmentJob skipped: Document ID #{document_id} not found.")
      return
    end

    # Execution Path: Call our enrichment service object
    CrmEnrichmentService.new(document).call
    Rails.logger.info("Successfully completed CrmEnrichmentJob for Document ID #{document.id}")
  rescue StandardError => e
    # Sad Path: Log failure and let Sidekiq retry with exponential backoff
    Rails.logger.error("CrmEnrichmentJob failed for Document ID #{document_id}: #{e.message}")
    raise e
  end
end