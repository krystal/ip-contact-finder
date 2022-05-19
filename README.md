# IP contact finder

This is a simple tool that uses RDAP to determine an array of authoritative email addresses for a given IP address or AS number.

## Installation

```ruby
gem 'ip_contact_finder', '~> 1.0'
```

## Usage

```ruby
# Lookup addresses for a given IP address
IPContactFinder.ip('8.8.8.8') #=> ['noc@example.com', 'abuse@example.com']

# Lookup addresses for a given AS number
IPContactFinder.autnum('60899') #=> ['noc@example.com', 'abuse@example.com']

# Catch errors which can be encountered while making lookups
begin
  IPContactFinder.ip('4.1.3.5')
rescue IPContactFinder::RDAP::NotFoundError
  # The given resource was not found
rescue IPContactFinder::RDAP::RateLimitedError
  # A rate limit was encountered, retry later
rescue IPContactFinder::RDAP::RequestError
  # A generic error occurred making the request
end

# If necessary, you can override which server the backend RDAP requests are
# sent to first.
IPContactFinder.rdap.server = 'rdap.arin.net'

# You can also configure a logger for the RDAP connections
IPContactFinder.rdap.logger = Logger.new($stdout)
```
