# frozen_string_literal: true

class EmbeddingGenerator
  # =========================================================================
  # PATH MAPPING:
  # - Hot Path: Successful API response returning a 1536-dimensional vector array.
  # - Execution Path: Calling OpenAI embeddings endpoint using text-embedding-3-small.
  # - Sad Path: Network timeouts, rate limits, or missing API key exceptions.
  # =========================================================================

  def self.call(text)
    client = OpenAI::Client.new

    # Execution Path: Request embedding generation from OpenAI
    response = client.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: text
      }
    )

    # Hot Path: Extract the embedding array from the response hash
    response.dig("data", 0, "embedding")
  rescue StandardError => e
    # Sad Path: Log the failure and re-raise or handle gracefully
    Rails.logger.error("EmbeddingGenerator Failed: #{e.message}")
    raise e
  end
end