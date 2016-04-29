var casper = require('casper').create({
    waitTimeout: 50000,
    pageSettings: {
        webSecurityEnabled: false  //no CORS
  }
});

var downloadUrl = '';
/*
 * output download url && apk file name, which delimited by '|'
 *
 * Todo: use command line arguments to input detail url of the android app,
 *       refer to: http://docs.casperjs.org/en/latest/cli.html
 *                 http://stackoverflow.com/questions/21765178/how-to-pass-a-variable-to-a-casperjs-script-through-the-command-line
*/
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

casper.run();