# frozen_string_literal: true

module IPContactFinder
  class Error < StandardError
  end

  class TooManyRedirectsError < Error
  end

  class RateLimitedError < Error
  end

  class NotFoundError < Error
  end

  class RequestError < Error
  end

  class InvalidObjectError < Error
  end
end
