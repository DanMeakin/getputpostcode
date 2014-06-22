# Helper module
#
# Contains helper functions for various requests made to the app.

# Make query on database
#
# This method accepts query parameters, reformats them and makes a query 
# on the database in the appropriate way. Because of the numerous fields 
# used by the PAF, it is convenient to have aliases when searching against 
# roads and towns. Without an alias, the user would require to know whether 
# the town being search is the town, or a dependent locality. Likewise for 
# roads.
#
# Instead, the query is performed by searching each of the town/locality fields
# and each of the thoroughfare fields and appending query results on each, 
# essentially creating an OR query against each of these.
#
# @param [Array<String>] params Parameters to be used in database query
# @return [Array<Address>]      Address instances representing query results
def make_query(params)
  road_keys = [:thoroughfare, :dependent_thoroughfare]
  town_keys = [:town, :dependent_locality, :dbl_dependent_locality]
  road      = params.delete("road")
  town      = params.delete("town")
  results   = Array.new

  # Append wildcards to each param
  query = Hash[params.map { |k, v| [k.to_sym.like, "%#{v}%"] }]
  { road_keys => road, town_keys => town }.each do |k, v|
    k.each do |key|
      query = query.merge({ key.like => "%#{v}%" })
      results += Address.all(query)
    end
  end
  results
end
