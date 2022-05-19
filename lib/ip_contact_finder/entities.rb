# frozen_string_literal: true

require 'ip_contact_finder/entity'

module IPContactFinder
  class Entities < Array
    def initialize(entities)
      super(entities.map { |e| Entity.new(e) })
    end

    # Return all the email addresses for this group of entities
    #
    # @return [Array<String>]
    def email_addresses
      addresses = []
      each do |entity|
        addresses |= entity.email_addresses
        addresses |= entity.entities.email_addresses
      end
      addresses.sort
    end
  end
end
