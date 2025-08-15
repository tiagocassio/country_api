namespace :swagger do
  desc "Generate Swagger documentation"
  task generate: :environment do
    puts "Generating Swagger documentation..."
    system("bundle exec rake rswag:specs:swaggerize")
    puts "Swagger documentation generated successfully!"
    puts "View at: http://localhost:3000/api-docs"
  end

  desc "Clean Swagger documentation"
  task clean: :environment do
    puts "Cleaning Swagger documentation..."
    FileUtils.rm_rf(Rails.root.join("swagger"))
    puts "Swagger documentation cleaned successfully!"
  end
end
