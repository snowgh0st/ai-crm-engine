# frozen_string_literal: true

OpenAI.configure do |config|
  # Execution Path: Fetch API key from environment variables
  config.access_token = ENV.fetch("OPENAI_API_KEY") { nil }
  config.log_errors = true # Logs failed requests for easy debugging
end