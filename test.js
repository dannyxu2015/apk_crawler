var casper = require('casper').create({
    waitTimeout: 50000,
    pageSettings: {
        webSecurityEnabled: false  //no CORS
  }
});

//casper.userAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4');

var fs = require('fs');
var downloadUrl = '';
var originApks = fs.list('.');

//casper.on('remote.message', function(message) {
//    this.echo(message);
//});

casper.start('http://coolapk.com/apk/com.obviousengine.seene.android.core').thenClick('a.btn.btn-success.ex-btn-glyphicon', function() {
    //this.echo('download button clicked');
});

casper.then(function dumpHeaders(){
  //console.log('Response headers');
  //console.log('-------------------------');
  this.currentResponse.headers.forEach(function(header){
    //console.log(header.name +': '+ header.value);
    if (header.name === 'Location') {
        downloadUrl = header.value;
        console.log(downloadUrl + '|' + downloadUrl.match(/([a-zA-Z0-9\s_\\.\-]+\.apk)/)[1]);
    }
  });
  //console.log('-------------------------');
});

/*
casper.then(function() {
    if (downloadUrl != '') {
      //console.log('downloading from ' + downloadUrl + ' ...');
      fn = downloadUrl.match(/([a-zA-Z0-9\s_\\.\-:]+\.apk)/)[1];
      console.log('downloading ' + fn + '...');
      casper.download(downloadUrl, fn);
    }
});
*/

/*
casper.then(function() {
    console.log('downloading by open download url ...');
    casper.open(downloadUrl);
});
*/

/*
casper.on('resource.received', function (resource) {
     "use strict";
     if ( (resource.url.indexOf(".apk") !== -1)) {
        this.echo('received from: ' + resource.url);
        var url, file;
        url = resource.url;
        file = "yyy.apk";
        try {
            this.echo("Attempting to download file " + file);
            var fs = require('fs');
            casper.download(resource.url, fs.workingDirectory+'/'+file);
        } catch (e) {
            this.echo('ERROR --> ' + e);
                    }
     }
 });
*/

/*
casper.start('http://coolapk.com/apk/com.obviousengine.seene.android.core', function() {
    firstUrl = this.getCurrentUrl();
    this.echo('Page title is: ' + this.evaluate(function() {
        console.log('from evaluate: ' + document.title);
        return document.title;
    }), 'INFO'); // Will be printed in green on the console
    this.evaluate(function(s) {
        document.querySelector(s).click();
    }, "a.btn.btn-success.ex-btn-glyphicon");
});
*/

/*
casper.waitFor(function check() {
    console.log((fs.list('.').toString() === originApks.toString()).toString());
    return fs.list('.').toString() != originApks.toString();
}, function then() {
    console.log('u got it, files: ' + fs.list('.').toString());
});
*/

casper.run();