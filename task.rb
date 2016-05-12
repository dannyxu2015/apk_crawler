require 'curb'
module Crawl
  module CoolApk
    class Task
      attr_reader :name, :done
      DELIMITER = "\t"

      def initialize(line)
        line  = '' if line.nil?
        t     = line.split(DELIMITER)
        @name = t[0]&.chomp
        @done = t[1] || '0'
        @easy ||= Curl::Easy.new
      end

      def nil?
        super.nil? || @name.nil? || @name.length == 0
      end

      def complete
        @done = '1'
      end

      def todo?
        @done == '0'
      end

      def completed?
        @done == '1'
      end

      def to_s
        [@name, @done].join(DELIMITER)
      end

      def download
        # warn "executing shell command: casperjs test.js #{@name}"
        res = %x(casperjs cool_apk.js #{@name})
        res.chomp!
        return false if $?.exitstatus > 0
        # warn 'Got: ' + "<#{res}>"
        apk_url, apk_name = res.split('|')
        process_download apk_url, apk_name
      end

      private

      def process_download(url, file_name)
        @easy.url = url
        warn "downloading #{file_name} ..."
        begin
          File.open(apk_name, 'wb') do |f|
            percent = 0.0
            count   = 0
            @easy.on_progress do |dl_total, dl_now, ul_total, ul_now|
              percent = dl_now / dl_total unless dl_total == 0.0
              # progress bar divided into 20 part
              if percent > 0.05*count
                print "="
                count += 1
              end
              true
            end
            @easy.on_body { |data| f << data; data.size }
            @easy.perform
            warn " Done!\n"
          end
          # Todo: record failed apk
        rescue => e
          warn "Failed !!! error: #{e.message}\n"
          return false
        end
        true
      end
    end

    class TaskFile < File
      APKS_FILE = 'cool_apks.txt'

      def initialize(access_str)
        @f   = ::File.open(APKS_FILE, access_str)
        @pos = 0
      end

      def rewind
        @f.rewind
      end

      def puts(line)
        @f.puts Task.new(line).to_s
      end

      def close
        @f.close
      end

      def gets
        @f.gets
      end

      def each(&block)
        @f.each { |l| block.call l }
      end

      def get_task
        @pos  = @f.pos
        @task = Task.new @f.gets&.chomp
      end

      def complete_task
        @f.seek @pos
        @task.complete
        @f.puts @task.to_s
      end
    end
  end
end