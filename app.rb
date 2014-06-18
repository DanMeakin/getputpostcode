# encoding: UTF-8
require 'json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'yaml'
require_relative 'models'

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
  "Welcome to Papi!"
end

get '/address' do
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-params'] }.to_json 
  end
  road_keys = [:thoroughfare, :dependent_thoroughfare]
  town_keys = [:town, :dependent_locality, :dbl_dependent_locality]
  road = params.delete("road")
  town = params.delete("town")
  query = Hash[params.map { |k, v| [k.to_sym.like, "%#{v}%"] }]
  results = Array.new
  road_keys.each do |road_key|
   query = query.merge({ road_key.like => "%#{road}%" })
   results += Address.all(query)
  end
  town_keys.each do |town_key|
    query = query.merge({ town_key.like => "%#{town}%" })
    results += Address.all(query)
  end
  results.to_json
end

get '/postcode' do
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-params'] }.to_json
  end
  Address.all(Hash[params.map { |k, v| [k.to_sym.like, "%#{v}%"] }]).to_json
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
        value = value.to_i
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


