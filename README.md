GetPutPostcode
==============

GetPutPostcode is provides a RESTful API for interacting with the data provided by the Royal Mail in their Postcode Address File (PAF).

This project will only be of interest to those with access to the PAF. Typically this will require a paid subscription, though registered charities with a turnover of less than £10m per annum can receive a copy of the database for free.

Installation & Usage
--------------------

Clone the repo and then run the app either using an existing webserver, or try it out by running app.rb from the root of the repo.

You can then make queries, create and update records in the database. The API accepts GET requests for database queries, POST requests for creation and update of records, and PUT requests for the update of existing records.

A query is authenticated by the API key set in the config file. You must include this API key as a parameter to any query made.

The address fields available to query against are:-

 * postcode
 * town
 * dependent_locality
 * dbl_dependent_locality
 * thoroughfare
 * dependent_thoroughfare
 * building_number
 * building_name
 * sub_building_name
 * households
 * department
 * organisation

Additionally, the "road" and "town" aliases are available for queries. If road is used, the query will select all records where the thoroughfare or dependent_thoroughfare contain road. If town is used, the query will select all records where the town, dependent_locality or dbl_dependent_locality contain town.
