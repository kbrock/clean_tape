require 'optparse'
require 'fileutils'
require 'logger'
require 'uri'

module CleanTape
  class Cli
    attr_accessor :options
    attr_accessor :args

    def initialize
      @options = {}
    end

    def runner
      @runner ||= Runner.new(options)
    end

    def run
      if options[:verbose]
        puts "options: #{options.inspect}"
        puts "files:    #{args.inspect}"
        puts
      end

      runner.run(args)
    end

    def parse(args, _env)
      self.args = args.dup
      self.options ||= {}

      options[:sort] = false
      options[:recorded_with] = true
      options[:recorded_at] = true
      # options[:hostname] = "foreman.example.com"
      # options[:username] = "username"
      # options[:password] = "password"
      #options[:dry_run] = true
      options[:request_headers] = true
      # options[:mac] = %w(mac)
      # options[:ip] = %w(ip ip_address)
      # options[:domain] = %w(domain_name)
      # options[:urls] = %w(url)

      OptionParser.new do |opts|
        opts.program_name = File.basename($0)
        opts.banner = "Usage: #{File.basename($0)} [options] [arg1] [arg2]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| options[:verbose] = v }
        #opts.on("-x", "--[no-]extras", "Run with extras (default: #{options[:extras]})") { |v| options[:extras] = v }
        opts.on("-s", "--[no-]sort", "Sort files by url (default: #{options[:sort]})") { |v| options[:sort] = v }
        opts.on("-r", "--recorded-with", "Normalize the recorded_with value") { |v| options[:recorded_with] = v }
        opts.on("-d", "--recorded-at", "Normalize the recorded_at date") { |v| options[:recorded_at] = v }
        opts.on("-g", "--guess", "Guess if the field contains an ip or mac address") { |v| options[:recorded_at] = v }
        opts.on("--[no-]dry-run", "Just see results don't actuall save anything") { |v| options[:dry_run] = v }
        opts.on("--json",         "Parse body as json") { |v| options[:json] = v}
        opts.on("--yaml",         "Parse body as yaml") { |v| options[:json] = v}
      end.parse!(self.args)

      self
    end
  end
end
