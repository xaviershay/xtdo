require 'date'
require 'yaml'

class Xtdo
  def self.run(store, operation)
    operation = operation.split(/\s+/)
    verb = operation.shift

#     tasks = {
#       'T1' => {:scheduled => Date.today}
#     }
    store = File.expand_path(store)
    tasks = if File.exists?(store)
      YAML.load(File.open(store))
    else
      {}
    end
    tasks[:tasks] ||= {}
    tasks[:recurring] ||= {}

    manager = Xtdo.new(tasks)

    ret = case verb
    when 'a' then # A is for add!
      manager.add operation.join(' ')
    when 'b' then # B is for bump!
      manager.bump operation.join(' ')
    when 'd' then # D is for done!
      manager.done operation.join(' ')
    when 'l' then # L is for list!
      case operation[0]
      when 'a' then
        manager.list [:today, :next, :scheduled]
      when 'c' then
        manager.list [:today, :next, :scheduled], :format => :completion
      else
        manager.list [:today]
      end
    when 'r' then # R is for recur!
      manager.recur operation.join(' ')
    end

    manager.save(store)
    ret
  end

  attr_reader :tasks, :recurring

  def initialize(tasks)
    @tasks = tasks[:tasks]
    @recurring = tasks[:recurring]
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
    @tasks[make_key task] = {:name => task}
    @tasks[make_key task][:scheduled] = parse_relative_time(number.to_i, period) if number
  end

  def bump(task)
    number, period, task = /^(?:(\d+)([dwmy])? )?(.*)/.match(task).captures
    if !number
      "Invalid time"
    elsif tasks[make_key task]
      tasks[make_key task][:scheduled] = parse_relative_time(number.to_i, period)
    else
      "No such task"
    end
  end

  def done(task)
    if tasks.delete(make_key task)
      "Task done"
    else
      "No such task"
    end
  end

  def list(groups, opts = {})
    # Check for recurring
    recurring.each do |name, task|
      if task[:next] <= Date.today
        tasks[make_key name] = {:scheduled => Date.today, :name => task[:name] }
        number, period, start, _ = self.class.extract_recur_tokens(task[:period] + ' ' + name)

        task[:next] = self.class.calculate_starting_day(Date.today, number, period, start)
      end
    end

    if opts[:format] == :completion
      tasks.keys.join "\n"
    else
      # Print groups
      task_selector = {
        :today     => lambda {|x| x && x <= Date.today },
        :next      => lambda {|x| !x },
        :scheduled => lambda {|x| x && x > Date.today }
      }

      groups.map do |group|
        t = tasks.select {|name, opts| task_selector[group][opts[:scheduled]] }
        next if t.empty?
        "\n\e[43;30m===== #{group.to_s.upcase} =====\e[0m\n\n" + t.map { |name, attrs|
          "  #{attrs[:name]}"
        }.join("\n")
      end.join("\n") + "\n\n"
    end
  end

  def recur(task)
    tokens = task.split(/\s+/)
    verb = tokens.shift
    task = tokens.join(' ')
    case verb
    when 'a' then
      number, period, start, name = self.class.extract_recur_tokens(task)

      period_string = "#{number}#{period}"
      period_string += ",#{start}" if start
      recurring[make_key name] = {
        :name   => name,
        :next   => Date.today + 1,
        :period => period_string
      }
    when 'd' then
      if recurring.delete make_key(task)
        "Recurring task removed"
      else
        "No such recurring task"
      end
    when 'l' then
      "\n\e[43;30m===== RECURRING =====\e[0m\n\n" + recurring.map do |name, task|
        "  %-8s%s" % [task[:period], task[:name]]
      end.join("\n") + "\n\n"
    when 'c' then
      recurring.keys.join "\n"
    end
  end

  def make_key(name)
    name.gsub /[^a-zA-Z0-9,.]/, '-' 
  end

  def self.calculate_starting_day(date, number, period, start = nil)
    days = %w(sun mon tue wed thu fri sat)
    number = (number || 1).to_i

    adjust = case period
    when 'd' then 1
    when 'w' then
      if days.index(start)
        (days.index(start) - date.wday) % 7 + (number - 1) * 7
      end
    when 'm' then
      start = start.to_i
      if start > 0
        year = date.year
        if start.to_i <= date.day
          month = date.month + 1
          if month > 12
            month = 1
            year += 1
          end
        else
          month = date.month
        end
        Date.new(year, month, start.to_i) - date
      end
    end
    if adjust
      if adjust == 0
        date + 7
      else
        date + adjust
      end
    end
  end

  def self.extract_recur_tokens(task)
    /^(\d+)([dwmy])?(?:,(#{days.join('|')}|\d{1,2}))? (.*)/.match(task).captures
  end
  def self.days
    days = %w(sun mon tue wed thu fri sat)
  end

  def save(file)
    File.open(file, 'w') {|f| f.write({
      :tasks     => tasks,
      :recurring => recurring,
      :version   => 1
    }.to_yaml) } 
  end
end
