# Include root element when serializing objects
ActiveModelSerializers.config.adapter = :json

# User fast optimized JSON for fast rendering
Oj.optimize_rails
