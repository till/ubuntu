#!/bin/bash

# deps, etc.
apt-get install -y jmeter-http jmeter-junit \
libxpp3-java libjboss-j2ee-java libcommons-net-java \
libjdom1-java

# patch the mofo
# https://bugs.launchpad.net/ubuntu/+source/jakarta-jmeter/+bug/457660

sed -i \
"s,find_jars junit libhtmlparser oro xalan2 xmlgraphics-commons xstream,find_jars junit libhtmlparser oro xalan2 xmlgraphics-commons xpp3 xstream,g" \
/usr/bin/jmeter

