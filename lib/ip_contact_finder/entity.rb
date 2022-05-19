# frozen_string_literal: true

require 'ip_contact_finder/entities'

module IPContactFinder
  class Entity
    def initialize(entity)
      @entity = entity

      lookup_vcard_from_rdap if @entity['vcardArray'].nil?
    end

    # Return all sub entities within this one
    #
    # @return [IPContactFinder::Entities]
    def entities
      return Entities.new([]) if @entity['entities'].nil?

      @entities ||= Entities.new(@entity['entities'])
    end

    # Return all email addresses for this entity
    #
    # @return [Array<String>]
    def email_addresses
      vcard = @entity['vcardArray']
      return [] if vcard.nil?
      return [] unless vcard[0] == 'vcard'

      components = vcard[1]
      version = components.find { |c| c[0] == 'version' }
      return [] unless version.last == '4.0'

      addresses = components.select { |c| c[0] == 'email' && c.last && c.last.length.positive? }
      addresses.map { |a| a.last.downcase }
    end

    private

    def lookup_vcard_from_rdap
      updated_entity = IPContactFinder.rdap.entity(@entity['handle'])
      @entity['vcardArray'] = updated_entity['vcardArray']
    end
  end
end
