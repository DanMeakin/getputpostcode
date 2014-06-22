# encoding: UTF-8
require 'json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'yaml'
require 'csv'
require_relative 'models'
require_relative 'helper'

CONFIG  = YAML.load_file('config/config.yaml')
API_KEY = CONFIG['api-key']
ERRORS  = CONFIG['error-messages']

configure :development do
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/development.db")
end

configure :test do
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/test.db")
end

DataMapper.auto_upgrade!
DataMapper.finalize

before do
  error 401 unless params[:key] == API_KEY
  params.delete("key")
end

get '/' do
  "Welcome to GetPutPostcode!"
end

get '/address' do
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-params'] }.to_json 
  end
  results = make_query(params)
  results.to_json
end

get '/postcode' do
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-params'] }.to_json
  end
  results = make_query(params)
  results.to_json
end

post '/update' do
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-update'] }.to_json
  end
  record_parameters = Hash.new
  address           = Address.new
  integer_fields    = [:id, :building_number, :households]
  params.each do |field, value|
    if address.respond_to? field
      if integer_fields.include?(field.to_sym)
        value = (value.nil? || value.empty?) ? nil : value.to_i
      end
      record_parameters.update({ field.to_sym => value })
    else
      halt 404, 
        {'Content-Type' => 'text/json'}, 
        { :error => "#{ERRORS['invalid-param']}: #{field}" }.to_json
    end
  end
  result = Address.first_or_create({ :id => record_parameters[:id] }, 
                                   record_parameters)
  if result.save
    record_parameters.to_json
  else
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['save-error'] }.to_json
  end
end

put '/update/:id' do
  params.reject! { |k, v| k == 'splat' || k == 'captures' }
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-update'] }.to_json
  end
  record_parameters = Hash.new
  address = Address.new
  params.each do |field, value|
    if address.respond_to? field
      record_parameters.update({ field.to_sym => value })
    else
      halt 404, 
        {'Content-Type' => 'text/json'}, 
        { :error => "#{ERRORS['invalid-param']}: #{field}" }.to_json
    end
  end
  result = Address.first_or_create({ :id => record_parameters[:id] }, 
                                   record_parameters)
  if result.save
    record_parameters.to_json
  else
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['save-error'] }.to_json
  end
end

get '/load-paf' do
  paf_path = "#{Dir.pwd}/data/PAF.csv"
  csvfile = if File.exist?(paf_path)
              File.open(paf_path)
            else
              halt 404,
                { 'Content-Type' => 'text/json' },
                { :error => ERRORS['missing-paf'] }.to_json
            end
  keys = 	[:postcode, :town, :dependent_locality, :dbl_dependent_locality, 
           :thoroughfare, :dependent_thoroughfare, :building_number,
           :building_name, :sub_building_name, :households, :department, 
           :organisation, :id, :postcode_type, :concat_indicator, 
           :small_user_indicator, :delivery_point_suffix]
  record_count = 0
  CSV.open(csvfile) do |csv|
    csv.each do |line|
      params = Hash[keys.zip(line)]
      record_params = Hash.new
      integer_fields    = [:id, :building_number, :households]
      params.each do |field, value|
        if integer_fields.include?(field.to_sym)
          value = (value.nil? || value.empty?) ? nil : value.to_i
        end
        record_params.update({ field.to_sym => value })
      end
      result = Address.first_or_create({ :id => record_params[:id] },
                                       record_params)
      if result.save
        puts record_params
        record_count += 1
      else
        raise "Unable to save! (#{record_params}"
      end
    end
  end
  { :records_saved => record_count }.to_json
end

