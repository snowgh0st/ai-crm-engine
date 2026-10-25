# frozen_string_literal: true

class Document < ApplicationRecord
  has_neighbors :embedding

  validates :title, presence: true
  validates :content, presence: true
  validates :source_type, presence: true

  before_save :generate_embedding_vector, if: -> { content.present? && (saved_change_to_content? || embedding.nil?) }
  
  # Hot Path: Automatically queue background AI enrichment once document is committed
  after_create_commit :enqueue_crm_enrichment

  scope :by_source, ->(type) { where(source_type: type) }

  private

  def generate_embedding_vector
    self.embedding = EmbeddingGenerator.call(content)
  rescue StandardError => e
    errors.add(:base, "Failed to generate AI embedding: #{e.message}")
    throw(:abort)
  end

  def enqueue_crm_enrichment
    CrmEnrichmentJob.perform_later(id)
  end
end