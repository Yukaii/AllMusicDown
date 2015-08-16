require_relative '../config'

require 'clockwork'

module Clockwork
  every(3.hours, 'alljp_crawler.job') { AlljpWorker.perform_async }
end
