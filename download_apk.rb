require 'curb'

if ARGV.length != 2
  puts 'Usage: ruby download_apk.rb apk_url apk_name'
  return
end
easy = Curl::Easy.new
easy.url = ARGV[0]
apk_name = ARGV[1]
puts "downloading #{apk_name}"
begin
  File.open(apk_name, 'wb') do |f|
    easy.on_progress {|dl_total, dl_now, ul_total, ul_now| print "="; true }
    easy.on_body {|data| f << data; data.size }
    easy.perform
    puts "download completed => '#{apk_name}'"
  end
# Todo: record failed apk  
rescue => e
  puts "download '#{apk_name}' failed, error: #{e.message}"
end