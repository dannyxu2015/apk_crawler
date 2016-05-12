/*
 * Usage:
 *   casperjs cool_apk.js
 *
 * @output String
 *   download url && apk file name, delimited by '|'
 *
 */

var casper = require('casper').create({
    waitTimeout: 5000,
    pageSettings: {
        webSecurityEnabled: false  //no CORS
  }
});

var url = 'http://coolapk.com/apk/com.obviousengine.seene.android.core';
var downloadUrl = '';

//refer: http://docs.casperjs.org/en/latest/cli.html
if (casper.cli.has(0)) {
  url = casper.cli.get(0);
}
casper.start(url).thenClick('a.btn.btn-success.ex-btn-glyphicon');

casper.then(function dumpHeaders(){
  this.currentResponse.headers.forEach(function(header){
    if (header.name === 'Location') {
        downloadUrl = header.value;
        console.log(downloadUrl + '|' + downloadUrl.match(/([a-zA-Z0-9\s_\\.\-]+\.apk)/)[1]);
    }
  });
});

casper.run();