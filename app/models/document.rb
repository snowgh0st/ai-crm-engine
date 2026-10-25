# frozen_string_literal: true

class Document < ApplicationRecord
  # =========================================================================
  # PATH MAPPING:
  # - Hot Path: Document created with auto-generated vector embedding.
  # - Execution Path: Callback triggering EmbeddingGenerator prior to database insert.
  # - Sad Path: Handled API failure or missing content preventing embedding.
  # =========================================================================

  has_neighbors :embedding

  validates :title, presence: true
  validates :content, presence: true
  validates :source_type, presence: true

  before_save :generate_embedding_vector, if: -> { content.present? && (saved_change_to_content? || embedding.nil?) }

  scope :by_source, ->(type) { where(source_type: type) }

  private

  def generate_embedding_vector
    # Execution Path: Generate vector coordinates via OpenAI
    self.embedding = EmbeddingGenerator.call(content)
  rescue StandardError => e
    # Sad Path: Fallback or prevent save if embedding is critical
    errors.add(:base, "Failed to generate AI embedding: #{e.message}")
    throw(:abort)
  end
end