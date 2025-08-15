every 1.day, at: "2:00 am" do
  UpdateCountriesJob.perform_later
end
