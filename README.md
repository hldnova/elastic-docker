# ELK Stack in Docker
Run the ELK (Elasticseach, Logstash, Kibana) stack with Docker and Docker-compose, based on the official images:
* [elasticsearch](https://registry.hub.docker.com/_/elasticsearch/)
* [logstash](https://registry.hub.docker.com/_/logstash/)
* [kibana](https://registry.hub.docker.com/_/kibana/)

# Setup
1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/)
3. Clone this repository

# Quick Start
Start the ELK stack with *docker-compose*:
```bash
$ cd elastic-docker
$ docker-compose up -d
```

To load sample dashboard:
```bash
$ cd dashboard/bin
$ ./boot.sh
```

To view dashboard, pointer your browser to  http://<your_elk_host>:5601 

# Configurations
Configurations are in their respective directories. Adjust *docker-compose.yml" and other configurations files as needed.
