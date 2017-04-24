#!/bin/bash
ES_ENDPOINT=${ES_ENDPOINT:-'http://localhost:9200'}
set -x
bin/import_dashboards -es ${ES_ENDPOINT} -dir . -only-dashboards

