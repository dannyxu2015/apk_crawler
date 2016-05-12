require 'curb'
require './task.rb'

tasks_file = Crawl::CoolApk::TaskFile.new("r+") rescue nil
if tasks_file.nil?
  puts 'Please generate task file cool_apks.txt first!'
  return 1
end

task = tasks_file.get_task
until task.nil?
  if task.todo?
    res = task.download
    tasks_file.complete_task if res
  end
  task = tasks_file.get_task
end
