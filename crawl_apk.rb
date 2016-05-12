require 'mechanize'
require 'nokogiri'
require 'spreadsheet'
require 'timeout'
require 'logger'
require './task.rb'
# require 'byebug'

module Crawl
  module CoolApk
    class CoolApk < Mechanize
      def initialize(connection_name = 'mechanize', options = {})
        @default_options = {
          xpath: {
            apks: '//ul/li[@class="media"]',
            apk:  {
              name:        'h4[@class="media-heading"]/a',
              url:         '@data-touch-url',
              logo:        'a/img/@src',
              version:     'span[@class="apk-version"]',
              description: 'div[@class="media-intro"]',
              other:       'span[@class="hidden-xs"]'
            }
          }
        }
        @options         = @default_options.merge(options)
        @apk             = @options[:xpath][:apk]
        @base_url        = 'http://coolapk.com'.freeze
        @logger          = Logger.new("coolapk_download_#{Time.now.strftime('%F-%T')}.log")
        super(connection_name)
      end

      def process(url)
        result   = []
        begin_at = Time.now

        warn "crawling #{url} ..."
        user_agent_alias = 'Mac Safari'
        get url
        pageno     = 0
        err_pageno = 0
        while page
          pageno += 1
          warn "page no: #{pageno}"
          (page / @options[:xpath][:apks]).each do |apk|
            apk_name     = (apk % @apk[:name])&.text
            apk_url      = (apk % @apk[:url])&.value
            apk_logo     = (apk % @apk[:logo])&.value
            apk_version  = (apk % @apk[:version])&.text
            apk_desc     = (apk % @apk[:description])&.text
            apk_other    = (apk % @apk[:other])&.text
            apk_size     = apk_other&.split('，')&.first
            apk_download = apk_other&.split('，')&.last
            next unless apk_url
            # warn apk_url.inspect
            begin
              transact do
                detail_url  = @base_url + apk_url
                # warn "detail page: #{detail_url}"
                detail_page = nil
                begin
                  Timeout::timeout(3) do
                    detail_page = get detail_url
                  end
                rescue
                  @logger.error detail_url
                end
                next unless detail_page
                apk = {
                  name:           apk_name,
                  url:            detail_url,
                  logo:           apk_logo,
                  version:        apk_version,
                  description:    apk_desc,
                  size:           apk_size,
                  download_count: apk_download
                }

                log_apk = apk.each_pair.map { |_, v| v }.join('\t')
                @logger.info log_apk
                warn log_apk
                result << apk
              end
            rescue => e
              warn e.message
              # warn e.backtrace.join("\n")
              err_pageno += 1
              next
            end
            return result if result.size > 5
          end
          next_page = (page / '//ul[@class="pagination"]/li/a/@href')[-2]&.value
          break if next_page.nil? || next_page =~ /###/
          # break if pageno >= 1
          # sleep a while
          # sleep 0.5
          get next_page
        end
        end_at = Time.now
        warn "Elasped: #{end_at - begin_at} seconds.\nGot #{result.size} records from #{url}, error: #{err_pageno}\nTotal page: #{pageno}, From #{begin_at.to_time} ~ #{end_at.to_time}"
        result
      end
    end
  end
end

# main()
puts 'Please input start page [1]:'
from_page = (p = gets.to_i) > 0 ? p : 1
url       = "http://coolapk.com/apk/?p=#{from_page}".freeze

task_file = Crawl::CoolApk::TaskFile.new('w+')

cool_apk = Crawl::CoolApk::CoolApk.new
ret      = cool_apk.process(url)
book     = Spreadsheet::Workbook.new
sheet    = book.create_worksheet(name: 'coolapk')
columns  = %w(名称 详情地址 logo 版本 描述 文件大小 下载次数)
sheet.row(0).concat columns

ret.each_with_index do |r, index|
  r.each_pair { |_, v| sheet.row(index + 2).push(v) }
  task_file.puts r[:url]
end
fn = "coolapk_#{Time.now.strftime('%F-%T')}.csv"
book.write(fn)
task_file.close