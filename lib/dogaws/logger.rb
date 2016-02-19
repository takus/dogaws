require 'logger'

module Dogaws

  @logger = ::Logger.new($stdout).tap do |logger|
    logger.level = Logger::INFO
  end

  class << self
    def logger
      @logger
    end
  end
end
