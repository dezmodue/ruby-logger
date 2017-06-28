#!/usr/bin/env ruby
require 'logstash-logger'

if ENV['LOGSTASH_HOST'].nil? || ENV['LOGSTASH_PORT'].nil? || ENV['LOG_DELAY'].nil?
  raise "Needed environmental variables: LOGSTASH_HOST, LOGSTASH_PORT, LOG_DELAY"
end

def logger
        stdout = [{ type: :stdout, formatter: ::Logger::Formatter }]
        remote = [{ type: :tcp, host: ENV['LOGSTASH_HOST'], port: ENV['LOGSTASH_PORT'],
                    formatter: :json_lines, sync: ENV.fetch('LOGSTASH_SYNC', 'true').downcase == 'true',
                    buffer_logger: Logger.new(STDOUT) }]

        @logger ||= LogStashLogger.new(
          type: :multi_logger,
          outputs: stdout + remote
        )
end

LogStashLogger.configure do |config|
  config.customize_event do |event|
    event['@system'] = ENV['LOGSTASH_SYSTEM_NAME'].nil? ? "system" : ENV['LOGSTASH_SYSTEM_NAME']
    event['@service'] = ENV['LOGSTASH_SERVICE_NAME'].nil? ? "service" : ENV['LOGSTASH_SERVICE_NAME']
    event['delay'] = ENV['LOG_DELAY']
    event['logger_type'] = 'ruby-logstash-logger'
  end
end

while true do
  logger.info 'Ruby logger checking in'
  sleep ENV['LOG_DELAY'].to_i
end
