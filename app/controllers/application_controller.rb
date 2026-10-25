class ApplicationController < ActionController::Base
  
  # Execution Path: Disable CSRF protection for stateless API namespaces
  skip_forgery_protection if -> { request.path.start_with?('/api/') }
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
