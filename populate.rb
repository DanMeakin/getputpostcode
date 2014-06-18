# Populates database with the contents of a local PAF.

require 'csv'
require_relative 'models'

csvfile = File.open("#{Dir.pwd}/data/PAF.csv")
keys = 	[:postcode, :town, :dependent_locality, :dbl_dependent_locality, 
         :thoroughfare, :dependent_thoroughfare, :building_number,
         :building_name, :sub_building_name, :households, :department, 
         :organisation, :id, :postcode_type, :concat_indicator, 
         :small_user_indicator, :delivery_point_suffix]

CSV.open(csvfile) do |csv|
  csv.each do |line|
    params = Hash[keys.zip(line)]
    result = Address.first_or_create({ :id => params[:id] },
                                     params)
    if result.save
      puts params
    else
      raise "Unable to save!"
    end
  end
end
