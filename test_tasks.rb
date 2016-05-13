require './task.rb'
tasks_file = Crawl::CoolApk::TaskFile.new("r+")

# each
puts '---------each------------'
tasks_file.each do |line|
  puts line
end

# get_task
puts '-----------get_task----------'
tasks_file.rewind
task = tasks_file.get_task
until task.nil?
  puts task.to_s
  task = tasks_file.get_task
end

# complete_task
tasks_file.rewind
task = tasks_file.get_task
until task.nil?
  tasks_file.complete_task
  task = tasks_file.get_task
end


# verify complete_task
puts '----------complete_task-----------'
tasks_file.rewind
tasks_file.each do |line|
  puts line
end


tasks_file.close