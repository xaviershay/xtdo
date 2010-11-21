require 'rspec'
require 'tempfile'
require 'date'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'xtdo'

RSpec.configure do |config|
  config.before :each do
    @file = Tempfile.new('xtdo')
  end

  config.after :each do
    @file.unlink
  end

  def t(operation)
    Xtdo.run @file.path, operation
  end
end

RSpec::Matchers.define(:have_task) do |task, opts = {}|
  match do |result|
    parsed = parse(result)
    tasks = opts[:in] ? parsed[opts[:in]] : parsed.values
    tasks.include?(task)
  end

  failure_message_for_should do |result|
    buffer = "Expected to find #{task} in #{opts[:in]}. Instead found:\n"
    parse(result).each do |group, tasks|
      buffer += "  #{group}\n"
      buffer += tasks.map {|x| "    #{x}" }.join("\n")
    end
    buffer
  end

  failure_message_for_should_not do |result|
    buffer = "Expected not to find #{task} in #{opts[:in]}:\n"
    parse(result).each do |group, tasks|
      buffer += "  #{group}\n"
      buffer += tasks.map {|x| "    #{x}" }.join("\n")
    end
    buffer
  end

  def parse(data)
    @parsed ||= begin
      group = nil
      data.lines.inject({}) do |a, line|
        if line =~ /^=+ (.+)/
          group = line[/^=+ (.+)/, 1].downcase.to_sym
        else
          a[group] ||= [] 
          a[group] << line.chomp
        end
        a
      end
    end
  end
end

module Steak
  module AcceptanceExampleGroup
    def self.included(base)
      base.instance_eval do
        alias scenario example
        alias background before
      end
    end
  end

  module DSL
    def feature(*args, &block)
      args << {} unless args.last.is_a?(Hash)
      args.last.update :type => :acceptance, :steak => true, :caller => caller   
      describe(*args, &block)
    end
  end
end

extend Steak::DSL

RSpec.configuration.include Steak::AcceptanceExampleGroup, :type => :acceptance
