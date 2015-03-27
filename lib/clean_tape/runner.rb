require 'json'
require 'yaml'

module CleanTape
  class Runner
    attr_accessor :verbose
    attr_accessor :recorded_with
    attr_accessor :recorded_at
    attr_accessor :request_headers
    attr_accessor :json
    attr_accessor :yaml
    attr_accessor :dry_run
    attr_accessor :sort

    def initialize(options = {})
      options.each do |name, value|
        send("#{name}=", value)
      end
    end

    def response_body # should I clean response_body?
      json || yaml
    end

    def cleaner
      BodyCleaner.new(parser)
    end

    def parser
      json ? JSON : YAML
    end

    def run(filenames)
      filenames.map { |filename| Tape.new(filename, verbose, cleaner)}.each do |f|
        f.clean_recorded_with   if recorded_with
        f.clean_recorded_at     if recorded_at

        f.clean_request_headers if request_headers
        # TODO: do in vcr itself
        #f.clean_request_uris(hostname, username, password)
        f.clean_request_body

        f.clean_response_headers
        f.clean_response_body if response_body

        f.sort if sort
        f.save unless dry_run
      end
    end

  end
end
