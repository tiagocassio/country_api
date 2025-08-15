json.id country.slug
json.extract! country, :id, :name, :alpha2_code, :alpha3_code, :latitude, :longitude, :official_name,
              :capital, :region, :subregion, :population, :area, :currencies, :language,
              :calling_code, :time_zones, :borders, :flag
json.url v1_country_url(country, format: :json)
