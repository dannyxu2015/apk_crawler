require 'mechanize'
require 'nokogiri'
require 'spreadsheet'
require 'timeout'
# require 'byebug'

module Apk
  module Crawl
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
        log_fn     = "coolapk_#{Time.now.strftime('%F-%T')}.log"
        log_file   = ::File.open(log_fn, 'w+')
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
                # warn "detail page: #{@base_url + apk_url}"
                detail_page = nil
                begin
                  Timeout::timeout(3) do
                    detail_page = get(@base_url + apk_url)
                  end
                rescue
                  #ignore detail page access error
                end
                next unless detail_page
                download_url = ''
                detail_page.css('script').each do |script|
                  if script.content =~ /apkDownloadUrl/
                    download_url = script.content.match(%r(apkDownloadUrl = "(.*)";))[1]
                  end
                end
                apk     = {
                  name:           apk_name,
                  url:            @base_url + download_url,
                  logo:           apk_logo,
                  version:        apk_version,
                  description:    apk_desc,
                  size:           apk_size,
                  download_count: apk_download
                }
                log_apk = apk.each_pair.map { |_, v| v }.join("\t")
                log_file.puts log_apk
                warn log_apk
                result << apk
                warn apk[:name] unless download_url == ''
              end
            rescue => e
              # warn e.message
              # warn e.backtrace.join("\n")
              err_pageno += 1
              next
            end
            # return result if result.size > 15
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

url = 'http://coolapk.com/apk/?p=1'.freeze

cool_apk = Apk::Crawl::CoolApk.new
ret      = cool_apk.process(url)
book     = Spreadsheet::Workbook.new
sheet    = book.create_worksheet(name: 'coolapk')
columns  = %w(名称 下载地址 logo 版本 描述 文件大小 下载次数)
sheet.row(0).concat columns

ret.each_with_index do |r, index|
  r.each_pair { |_, v| sheet.row(index + 2).push(v) }
end
fn = "coolapk_#{Time.now.strftime('%F-%T')}.csv"
book.write(fn)
