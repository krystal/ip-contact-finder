# frozen_string_literal: true

require 'ipaddr'
require 'ip_contact_finder/rdap'
require 'ip_contact_finder/entities'

module IPContactFinder
  class << self
    IPV4_REGEXP = /\A[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\z/.freeze
    IPV6_REGEXP = /\A[a-f0-9]+:[a-f0-9:]+\z/i.freeze
    AUTNUM_REGEXP = /\A[0-9]+\z/.freeze
    ENTITY_REGEXP = /\A[a-z\-_0-9]+\z/i.freeze

    def rdap
      @rdap ||= RDAP.new
    end

    def lookup(object)
      case object
      when AUTNUM_REGEXP
        autnum(object)
      when IPV4_REGEXP, IPV6_REGEXP
        ip(object)
      else
        entity(object)
      end
    end

    def ip(ip)
      raise InvalidObjectError, "IP address given doesn't look at a valid IP address" unless valid_ip?(ip)

      result = rdap.ip(ip)
      Entities.new(result['entities']).email_addresses
    end

    def autnum(autnum)
      raise InvalidObjectError, "Autnum given doesn't look at a valid autnum" unless autnum.match?(AUTNUM_REGEXP)

      result = rdap.autnum(autnum)
      Entities.new(result['entities']).email_addresses
    end

    def entity(entity)
      raise InvalidObjectError, "Entity given doesn't look at a valid entity" unless entity.match?(ENTITY_REGEXP)

      result = rdap.entity(entity)
      Entities.new([result]).email_addresses
    end

    private

    def valid_ip?(ip)
      return false unless ip.match?(IPV4_REGEXP) || ip.match?(IPV6_REGEXP)

      IPAddr.new(ip)
      true
    rescue IPAddr::InvalidAddressError
      false
    end
  end
end
