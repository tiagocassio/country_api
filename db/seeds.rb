def extract_currencies(currencies_data)
  return nil if currencies_data.blank?

  if currencies_data.is_a?(Hash)
    currencies_data.map do |code, currency_info|
      if currency_info.is_a?(Hash)
        "#{code}: #{currency_info['name']} (#{currency_info['symbol']})"
      else
        code.to_s
      end
    end.join(', ')
  else
    currencies_data.to_s
  end
end

def extract_languages(languages_data)
  return nil if languages_data.blank?

  if languages_data.is_a?(Hash)
    languages_data.map do |code, language_name|
      "#{code}: #{language_name}"
    end.join(', ')
  else
    languages_data.to_s
  end
end

def safe_join(data, separator = ', ')
  return nil if data.blank?
  data.is_a?(Array) ? data.join(separator) : data.to_s
end

puts "🌱 Starting database seeding..."

# Create a default user
puts "👤 Creating default user..."
user = User.find_or_create_by!(email: 'user@example.com') do |u|
  u.password = '123456789'
  u.password_confirmation = '123456789'
  u.verified = true
end
puts "✅ User created: #{user.email}"

# Fetch countries from the API
puts " Fetching countries from Country API..."
client = CountryApi::Client.new
countries_data = client.v1.all_countries

if countries_data
  puts "📡 Found #{countries_data.length} countries from API"

  # Create or update countries
  countries_data.each do |country_code, country_data|
    # Extract the country information from the API response
    # Based on the actual API response structure
    country_attrs = {
      name: country_data['name'],
      alpha2_code: country_data['alpha2Code'],
      alpha3_code: country_data['alpha3Code'],
      latitude: country_data.dig('latLng', 'country', 0)&.to_s,
      longitude: country_data.dig('latLng', 'country', 1)&.to_s,
      official_name: country_data['official_name'],
      capital: country_data['capital'],
      region: country_data['region'],
      subregion: country_data['subregion'],
      population: country_data['population']&.to_s,
      area: country_data['area']&.to_s,
      currencies: extract_currencies(country_data['currencies']),
      language: extract_languages(country_data['languages']),
      calling_code: country_data['callingCode'],
      time_zones: safe_join(country_data['timezones']),
      borders: safe_join(country_data['borders']),
      flag: country_data.dig('flag', 'large') || country_data.dig('flag', 'medium') || country_data.dig('flag', 'small')
    }.compact

    # Find or create the country
    country = Country.find_or_create_by!(alpha2_code: country_attrs[:alpha2_code]) do |c|
      country_attrs.each { |key, value| c.send("#{key}=", value) if c.respond_to?("#{key}=") }
    end

    # Update existing country if it exists
    if country.persisted? && country.updated_at < 1.day.ago
      country.update!(country_attrs)
      puts " Updated: #{country.name}"
    elsif country.new_record?
      puts "✨ Created: #{country.name}"
    end
  end

  puts "✅ Successfully processed #{Country.count} countries"
else
  puts "❌ Failed to fetch countries from API"
  puts " Make sure you have configured the country_api API key in your credentials"
  puts "💡 Run: docker compose exec web rails credentials:edit"
end

puts "🎉 Database seeding completed!"
