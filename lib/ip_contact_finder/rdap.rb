# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'ip_contact_finder/error'
require 'ip_contact_finder/version'

module IPContactFinder
  class RDAP
    DEFAULT_SERVER = 'rdap.db.ripe.net'

    attr_reader :server
    attr_reader :logger

    def initialize(server: DEFAULT_SERVER, logger: nil)
      @server = server
      @logger = logger
    end

    def lookup(type, object)
      request(create_initial_url(type, object))
    end

    def ip(object)
      lookup('ip', object)
    end

    def autnum(object)
      lookup('autnum', object)
    end

    def entity(object)
      lookup('entity', object)
    end

    private

    def create_initial_url(type, object)
      "https://#{@server}/#{type}/#{object}"
    end

    def request(uri, redirect_count: 0)
      raise TooManyRedirectsError, 'Too many redirects' if redirect_count >= 5

      uri = URI.parse(uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri.path)
      request['User-Agent'] = "IP Contact Finder/#{IPContactFinder::VERSION}"

      @logger&.info "Making request to #{uri}"

      http.start
      response = http.request(request)
      @logger&.info "Got response #{response.code}"

      case response
      when Net::HTTPRedirection
        new_location = response['Location']
        request(new_location, redirect_count: redirect_count + 1)
      when Net::HTTPOK
        JSON.parse(response.body)
      when Net::HTTPTooManyRequests
        raise RateLimitedError
      when Net::HTTPNotFound
        raise NotFoundError
      else
        raise RequestError, "Got status #{response.code} (#{response.body})"
      end
    rescue SocketError, Errno::ECONNRESET, EOFError, Errno::EINVAL, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
           Errno::ECONNREFUSED, OpenSSL::SSL::SSLError, Timeout::Error => e
      raise RequestError, "#{e.message} (#{e.class})"
    ensure
      http.finish
    end
  end
end
