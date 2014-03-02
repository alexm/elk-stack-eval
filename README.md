ELK Stack Eval
==============

Steps
-----

    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb
    wget http://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.3.3-1-debian_all.deb
    wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.0milestone5.tar.gz
    git submodule update --init
    vagrant up
    x-www-browser http://localhost:8080/kibana
    x-www-browser http://localhost:8080/elasticsearch-head

References
----------

* http://cookbook.logstash.net/recipes/rsyslog-agent/
* https://medium.com/what-i-learned-building/e855bc08975d
