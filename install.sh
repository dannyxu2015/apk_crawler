wget https://phantomjs.googlecode.com/files/phantomjs-1.9.1-linux-x86_64.tar.bz2
bunzip2 phantomjs-1.9.1-linux-x86_64.tar.bz2 
tar xf phantomjs-1.9.1-linux-x86_64.tar 
mv phantomjs-1.9.1-linux-x86_64/ /opt/
ln -s /opt/phantomjs-1.9.1-linux-x86_64/ /opt/phantomjs
ln -s /opt/phantomjs/bin/phantomjs /usr/local/bin/

#check what you've just done
which phantomjs
phantomjs --version

#start installing casperjs
git clone https://github.com/n1k0/casperjs.git 
mv casperjs/ /opt/casperjs
ln -s /opt/casperjs/bin/casperjs  /usr/local/bin/

#check what you've just done
which casperjs
casperjs --version
