require 'yaml'
require 'date'

tasks = if File.exists?("tasks.yml")
  YAML.load(File.open("tasks.yml").read)
else
  {}
end


RELATIVE_REGEX = /^(\d+)([dwmy])?$/

def parse_relative_time(str)
  number   = str[RELATIVE_REGEX, 1].to_i
  modifier = str[RELATIVE_REGEX, 2]
  adj = {
    'd' => 1,
    'w' => 7,
    'm' => 30,
    'y' => 365
  }[modifier] || 1
  Date.today + adj * number
end

case ARGV[0]
when 'add' then 
  task = ARGV[1..-1]
  if task[0] =~ RELATIVE_REGEX
    scheduled_for = parse_relative_time(task.shift)
    puts "Adding task: #{task.join(' ')} for #{scheduled_for}"
    tasks[task.join(' ')] = {:scheduled => scheduled_for} # TODO: if already exists?
  else
    puts "Adding task: #{task.join(' ')}"
    tasks[task.join(' ')] = {} # TODO: if already exists?
  end
when 'done' then puts "done task"
when 'list' then
  today = Date.today
  today_tasks = tasks.select {|name, attrs| attrs[:scheduled] && attrs[:scheduled] <= today }
  puts "==== TODAY ====="
  puts today_tasks.keys.sort

  if ARGV[1] == 'all'
    puts
    puts "===== NEXT ====="
    next_tasks = tasks.select {|name, attrs| !attrs[:scheduled] }
    puts next_tasks.keys.sort
    puts
    puts "===== SCHEDULED ====="
    scheduled_tasks = tasks.select {|name, attrs| attrs[:scheduled] }.delete_if{|k, v| today_tasks.keys.include?(k)}
    puts scheduled_tasks.sort_by{|name, attrs| attrs[:scheduled] }.map {|name, attrs| "#{attrs[:scheduled]}\t#{name}"}.join("\n")
  end
#   puts
# 
#   puts tasks.map {|name, attrs| "#{name}\t#{attrs[:scheduled]}"}.join("\n")
end

# TODO: Two step write incase of crash
File.open("tasks.yml", "w") do |f|
  f.write tasks.to_yaml
end
