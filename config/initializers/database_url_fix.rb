# Fix incomplete DATABASE_URL from Render
# Render sometimes provides DATABASE_URL without port and full domain
if Rails.env.production? && ENV["DATABASE_URL"].present?
  db_url = ENV["DATABASE_URL"]
  
  begin
    # Parse the URL
    uri = URI.parse(db_url)
    host = uri.host
    
    # Check if hostname is incomplete (missing domain) or port is missing
    if host && host.start_with?("dpg-") && !host.include?(".")
      # Hostname is incomplete (like dpg-xxxxx-a), add .render.com
      # Render PostgreSQL databases typically use .render.com for internal connections
      fixed_host = "#{host}.render.com"
      uri.host = fixed_host
      
      Rails.logger.info "Fixed incomplete hostname: #{host} -> #{fixed_host}"
    end
    
    # Add port if missing (PostgreSQL default is 5432)
    if uri.port.nil?
      uri.port = 5432
      Rails.logger.info "Added missing port 5432 to DATABASE_URL"
    end
    
    # Update ENV with fixed URL if it changed
    fixed_url = uri.to_s
    if fixed_url != db_url
      ENV["DATABASE_URL"] = fixed_url
      Rails.logger.info "Fixed DATABASE_URL: #{db_url} -> #{fixed_url}"
    end
  rescue URI::InvalidURIError => e
    Rails.logger.error "Failed to parse DATABASE_URL: #{e.message}"
  end
end

