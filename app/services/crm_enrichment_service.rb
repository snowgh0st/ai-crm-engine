# frozen_string_literal: true

class CrmEnrichmentService
  # =========================================================================
  # PATH MAPPING:
  # - Hot Path: Successfully enriching CRM text with AI-generated structured metadata.
  # - Execution Path: Combining vector similarity search context with OpenAI structured completions.
  # - Sad Path: Handling JSON parsing failures or API timeouts gracefully.
  # =========================================================================

  def initialize(document)
    @document = document
  end

  def call
    client = OpenAI::Client.new

    # Execution Path: Fetch relevant contextual documents via vector search
    context_docs = Document.nearest_neighbors(:embedding, @document.embedding, distance: 'cosine').limit(3)
    context_text = context_docs.map { |d| "- #{d.title}: #{d.content}" }.join("\n")

    prompt = <<~PROMPT
      Analyze the following CRM document and contextual history to provide structured enrichment.
      Return ONLY a valid JSON object with these keys: "sentiment" (positive, neutral, negative), "priority" (low, medium, high, urgent), "action_items" (array of strings), and "account_tag" (string).

      Contextual History:
      #{context_text}

      Target Document:
      Title: #{@document.title}
      Content: #{@document.content}
    PROMPT

    # Execution Path: Request structured analysis from OpenAI
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        response_format: { type: "json_object" }
      }
    )

    content_str = response.dig("choices", 0, "message", "content")
    parsed_enrichment = JSON.parse(content_str)

    # Hot Path: Merge AI enrichment into document metadata and save
    updated_metadata = (@document.metadata || {}).merge("enrichment" => parsed_enrichment)
    @document.update!(metadata: updated_metadata)

    Rails.logger.info("Successfully enriched Document ID #{@document.id} with CRM metadata.")
    parsed_enrichment
  rescue StandardError => e
    # Sad Path: Log error but prevent crash
    Rails.logger.error("CrmEnrichmentService failed for Document ID #{@document.id}: #{e.message}")
    raise e
  end
end