require 'rest_client'
require 'json'

module Hover
  # API class
  class Api
    URL = 'https://www.hover.com/api/'.freeze
    AUTH_URL = 'https://www.hover.com/signin/auth.json'.freeze

    attr_accessor :client, :username, :password

    def initialize(username, password)
      self.username = username
      self.password = password

      begin
        session = authenticate(username, password)
      rescue StandardError => e
        puts e.message
        puts e.backtrace
      end

      self.client = RestClient::Resource.new(URL,
                                             cookies: { hoverauth: session })
    end

    def authenticate(username, password)
      auth = { username: username, password: password }
      RestClient.post(AUTH_URL, auth) do |response, _request, _result|
        raise StandardError,
              'Failed to authenticate' unless response.code == 200
        response.cookies['hoverauth']
      end
    end

    def domains(params = {})
      response = get('domains', params)
      JSON.parse(response)['domains']
    end

    def dns(params = {})
      response = get('dns', params)
      JSON.parse(response)['domains']
    end

    def domain(id, params = {})
      response = get("domains/#{id}", params)
      JSON.parse(response)['domain']
    end

    def domain_dns(id, params = {})
      response = get("domains/#{id}/dns", params)
      JSON.parse(response)['domains'].first['entries']
    end

    def create_record(id, name, type, content)
      params = { name: name, type: type, content: content }
      response = post("domains/#{id}/dns", params)
      JSON.parse(response)
    end

    def update_record(id, params = {})
      response = put("dns/#{id}", params)
      JSON.parse(response)
    end

    [:get, :put, :post, :delete].each do |method|
      define_method(method) do |path, params = {}|
        client[path].send(method, params)
      end
    end
  end
end
