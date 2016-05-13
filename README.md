## Environment

ruby v2.3.0

**gems:**

* mechanize
* nokogiri
* spreadsheet
* curb
* byebug(only for debug, optional)

### Usage
    ruby crawl_apk.rb
        
will output an excel format .csv file & a plain text .log file for all android apps.

and will output `cool_apks.txt`, an applications URL list text file.


    ruby download_apk.rb
    
which will start to download android applications which list in 'cool_apks.txt' and record the download status, you can resume it anytime after it broken.

**Note:** the list file will be OVERWRITTEN each time you run the crawl_apk.rb! so please keep a backup of it.