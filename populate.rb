require 'net/http'
require 'open-uri'
require 'json'
require 'csv'

csvfile = File.open("#{Dir.pwd}/sample_data/CSV PAF/CSV PAF.csv")
keys = 	[:postcode, :town, :dependent_locality, :dbl_dependent_locality, 
         :thoroughfare, :dependent_thoroughfare, :building_number,
         :building_name, :sub_building_name, :households, :department, 
         :organisation, :id, :postcode_type, :concat_indicator, 
         :small_user_indicator, :delivery_point_suffix]
url = URI("http://localhost:4567/update")
http = Net::HTTP.new(url.hostname, url.port)

CSV.open(csvfile) do |csv|
  csv.each do |line|
    params = Hash[keys.zip(line)]
    request = Net::HTTP::Post.new("/v1.1/auth")
    request.add_field("Content-Type", "application/json")
    request.body = params.to_json
    response = http.request(request)
    puts response
  end
end
