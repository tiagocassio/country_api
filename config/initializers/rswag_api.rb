Rswag::Api.configure do |c|
  c.openapi_root = Rails.root.to_s + "/swagger"
  c.swagger_filter = lambda { |swagger, env| swagger }
end
