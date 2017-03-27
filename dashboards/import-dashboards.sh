#!/bin/bash
set -x
bin/import_dashboards -es http://localhost:9200 -dir . -only-dashboards

