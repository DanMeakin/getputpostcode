# encoding: UTF-8

# The Address class is used to represent entries in the Postcode Address File,
# with each row in the file represented by an instance of Address.
#
# The PAF is available in CSV format - this class is designed for use with the 
# CSV file format. All of the data contained within the CSV PAF can be stored 
# using the fields defined below. 
#
# Each row of the CSV PAF contains the following fields in the 
# following order:-
#
# 1.  Postcode;
# 2.  Town;
# 3.  Dependent Locality;
# 4.  Double Dependent Locality;
# 5.  Thoroughfare;
# 6.  Dependent Thoroughfare;
# 7.  Building Number;
# 8.  Building Name;
# 9.  Sub-Building Name;
# 10. Households;
# 11. Department;
# 12. Organisation;
# 13. Address Key;
# 14. Postcode Type;
# 15. Concatenation Indicator;
# 16. Small Users Organisation Indicator;
# 17. Delivery Point Suffix.
#
# 
class Address
	include DataMapper::Resource

	property :id, 										Integer, :key      => true
	property :postcode, 							String,  :required => true
	property :town, 									String,  :required => true
	property :dependent_locality, 		String
	property :dbl_dependent_locality, String
	property :thoroughfare, 					String,  :length   => 81
	property :dependent_thoroughfare, String 
	property :building_number, 				Integer
	property :building_name, 					String
	property :sub_building_name, 			String
	property :po_box, 						    Integer
	property :department, 						String,  :length   => 60
	property :organisation, 					String,  :length   => 60
	property :postcode_type, 					String
	property :concat_indicator, 			String
	property :small_user_indicator, 	String
	property :delivery_point_suffix, 	String

  validates_with_method :postcode, :method => :valid_postcode?

  def valid_postcode?
    postcode_regex = /^(GIR\s0AA)|
                        (
                         (
                          ([A-PR-UWYZ][0-9]{1,2})|(
                            ([A-PR-UWYZ][A-HK-Y][0-9]{1,2})|
                            (
                              ([A-PR-UWYZ][0-9][A-HJKSTUW])|
                              ([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY])
                            )
                          )
                        )\s[0-9][ABD-HJLNP-UW-Z]{2})$/x
    !!(postcode =~ postcode_regex)
  end
end
