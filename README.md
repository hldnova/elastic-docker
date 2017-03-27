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
$ cd ecs-dashboard/docker-elk
$ docker-compose up
```
Or run in detached mode
```bash
$ docker-compose up -d
```
Optionally, load metricbeat sample dashboards if you want some dashboard to start with. A metricbeat container is started to collect system data from the docker host. The container name should be *dockerelk_metricbeat_1* 

```bash
$ docker exec dockerelk_metricbeat_1 /metricbeat/scripts/import_dashboards -es http://elasticsearch:9200
```
Access Kibana UI [http://<docker_box>:5601](http://<docker_box>:5601) with a web browser. Note that you will need to select an index pattern first, e.g., **metricbeat-***. Then click **Dashboard** and open an sample dashboard by clicking **Open** button on the top right area.

# Configurations
Configurations are under docker-elk in their respective directories.Adjust *docker-compose.yml" and other configurations files as needed.
