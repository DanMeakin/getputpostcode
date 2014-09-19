# encoding: UTF-8
require 'json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'yaml'
require 'csv'
require_relative 'models'
require_relative 'helper'
require_relative 'formatter'

CONFIG  = YAML.load_file('config/config.yaml')
API_KEY = CONFIG['api-key']
ERRORS  = CONFIG['error-messages']

configure :development do
  #DataMapper::Logger.new($stdout, :debug)
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

['/address', '/postcode'].each do |path|
  get path do
    if params.empty?
      halt 404, 
        {'Content-Type' => 'text/json'}, 
        { :error => ERRORS['empty-params'] }.to_json 
    end
    formatted = params.delete("formatted") == "true"
    results   = make_query(params)
    results.map do |addr| 
      formatted ? AddressFormatter.format_address(addr) : addr
    end.to_json
  end
end

post '/update' do
  if params.empty?
    halt 404, 
      {'Content-Type' => 'text/json'}, 
      { :error => ERRORS['empty-update'] }.to_json
  end
  record_parameters = Hash.new
  address           = Address.new
  integer_fields    = [:id, :building_number, :po_box]
  params.each do |field, value|
    if address.respond_to? field
      if integer_fields.include?(field.to_sym)
        value = (value.nil? || value.strip.empty?) ? nil : value.to_i
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
  integer_fields = [:id, :building_number, :po_box]
  params.each do |field, value|
    if address.respond_to? field
      if integer_fields.include?(field.to_sym)
        value = (value.nil? || value.strip.empty?) ? nil : value.to_i
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

