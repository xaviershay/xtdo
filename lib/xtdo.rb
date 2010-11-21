require 'date'
require 'yaml'

class Xtdo
  def self.run(store, operation)
    operation = operation.split(/\s+/)
    verb = operation.shift

#     tasks = {
#       'T1' => {:scheduled => Date.today}
#     }
    tasks = YAML.load(File.open(store)) || {}

    manager = Xtdo.new(tasks)

    ret = case verb
    when 'a' then # A is for add!
      manager.add operation.join(' ')
    when 'b' then # B is for bump!
      manager.bump operation.join(' ')
    when 'l' then # L is for list!
      manager.list [:today, :next, :scheduled]
    end

    manager.save(store)
    ret
  end

  attr_reader :tasks

  def initialize(tasks)
    @tasks = tasks
  end

  def parse_relative_time(number, period)
    adj = {
      'd' => 1,
      'w' => 7,
      'm' => 30,
      'y' => 365
    }[period] || 1
    Date.today + adj * number
  end

  def add(task)
    number, period, task = /^(?:(\d+)([dwmy])? )?(.*)/.match(task).captures
    @tasks[task] = {}
    @tasks[task][:scheduled] = parse_relative_time(number.to_i, period) if number
  end

  def bump(task)
    number, period, task = /^(?:(\d+)([dwmy])? )?(.*)/.match(task).captures
    if !number
      "Invalid time"
    elsif tasks[task]
      tasks[task][:scheduled] = parse_relative_time(number.to_i, period)
    else
      "No such task"
    end
  end

  def list(groups)
    task_selector = {
      :today     => lambda {|x| x && x <= Date.today },
      :next      => lambda {|x| !x },
      :scheduled => lambda {|x| x && x > Date.today }
    }

    groups.map do |group|
      t = tasks.select {|name, opts| task_selector[group][opts[:scheduled]] }
      "===== #{group.to_s.upcase}\n" + t.map { |name, attrs|
        name
      }.join("\n")
    end.join("\n")
  end
  
  def save(file)
    File.open(file, 'w') {|f| f.write tasks.to_yaml } 
  end
end
