require 'rspec'
require 'tempfile'
require 'date'
require 'timecop'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'xtdo'

RSpec.configure do |config|
  config.before :each do
    @file = File.join(Dir.tmpdir, 'xtdo_test.yml')
  end

  config.after :each do
    File.unlink @file if File.exists? @file
    Timecop.return
  end

  def t(operation)
    Xtdo.run @file, operation
  end
  
  def time_travel(time)
    Timecop.travel(time)
  end
end

RSpec::Matchers.define(:have_completion_task) do |task|
  match do |result|
    parse(result).include? task
  end

  failure_message_for_should do |result|
    buffer = "Expected to find #{task}. Instead found:\n"
    parse(result).each do |found|
      buffer += "  #{found}"  
    end
    buffer
  end

  def parse(data)
    data.to_s.lines.map(&:chomp)
  end
end

RSpec::Matchers.define(:have_task) do |task, opts = {}|
  match do |result|
    parsed = parse(result)
    tasks = opts[:in] ? parsed[opts[:in]] : parsed.values.flatten
    tasks && tasks.include?(task)
  end

  failure_message_for_should do |result|
    in_string = " in #{opts[:in]}" if opts[:in]
    buffer = "Expected to find #{task}#{in_string}. Instead found:\n"
    parse(result).each do |group, tasks|
      buffer += "  #{group}\n"
      buffer += tasks.map {|x| "    #{x}" }.join("\n")
      buffer += "\n"
    end
    buffer
  end

  failure_message_for_should_not do |result|
    in_string = " in #{opts[:in]}" if opts[:in]
    buffer = "Expected not to find #{task}#{in_string}:\n"
    parse(result).each do |group, tasks|
      buffer += "  #{group}\n"
      buffer += tasks.map {|x| "    #{x}" }.join("\n")
      buffer += "\n"
    end
    buffer
  end

  def parse(data)
    @parsed ||= begin
      group = nil
      data.to_s.lines.reject {|x| x.chomp.length == 0 }.inject({}) do |a, line|
        if line =~ /^[^\s]+=+ (.+) =/
          group = line[/^[^\s]+=+ (.+) =/, 1].downcase.to_sym
        else
          a[group] ||= [] 
          a[group] << line.strip
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
