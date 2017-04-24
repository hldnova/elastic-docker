#!/bin/sh
########################################################################
# Boot script gets executed whenever the container is created
# Use this script to install/configure any bits on the container
# This script file should be available under /vipr-share folder
# in the host machine and the folder will be visible to the container
########################################################################

export PATH=/bin:/bin:/sbin:/usr/bin:/usr/sbin

SHARED_LOGS_VOLUME='/var/log'
DASHBOARD_BASE='../../dashboard'
VISUALIZATION_PATH=${DASHBOARD_BASE}/visualization
SEARCH_PATH=${DASHBOARD_BASE}/search
DASHBOARD_PATH=${DASHBOARD_BASE}/dashboard
KIBANA_VERSION=5.1.2
ES_ENDPOINT='http://10.247.134.224:9200'

    curl -XPUT -f ${ES_ENDPOINT}/_template/enable_dynamic_mappings -d '
    {
      "order": 0,
      "template": "*",
      "mappings": {
         "_default_": {
             "numeric_detection": true
         }
      } 
    }'

# create template for general navigation
    curl -XPUT -f ${ES_ENDPOINT}/_template/navigation -d@./navigation_template.json

    curl -XPUT -f ${ES_ENDPOINT}/_bulk  --data-binary @./navigation_category.json

# create template for accesslog 
    curl -XPUT -f ${ES_ENDPOINT}/_template/accesslog -d@./accesslog_template.json

# create template for metricbeat
    curl -XPUT -f ${ES_ENDPOINT}/_template/metricbeat -d@./metricbeat_template.json

# create template for ecsbeat
    curl -XPUT -f ${ES_ENDPOINT}/_template/ecsbeat -d@./ecsbeat_template.json

    curl -XPUT -f ${ES_ENDPOINT}/.kibana/index-pattern/accesslog-* -d@./accesslog_field_update.data

    curl -XPUT -f ${ES_ENDPOINT}/.kibana/index-pattern/metricbeat-* -d@./metricbeat_field_update.data

    curl -XPUT -f ${ES_ENDPOINT}/.kibana/index-pattern/ecsbeat-* -d@./ecsbeat_field_update.data

    curl -XPUT -f ${ES_ENDPOINT}/.kibana/index-pattern/navigation -d@./navigation_field_update.data

    curl -XPUT -f ${ES_ENDPOINT}/.kibana/config/${KIBANA_INDEX} -d '{"defaultIndex" : "navigation"}'

    cd ${VISUALIZATION_PATH}
    for i in `ls -1`; do 
        fname=`basename $i .json`
        curl -XPUT -f ${ES_ENDPOINT}/.kibana/visualization/${fname} -d@$i
    done

    cd ${SEARCH_PATH}
    for i in `ls -1`; do 
        fname=`basename $i .json`
        curl -XPUT -f ${ES_ENDPOINT}/.kibana/search/${fname} -d@$i
    done

    cd ${DASHBOARD_PATH}
    for i in `ls -1`; do 
        fname=`basename $i .json`
        curl -XPUT -f ${ES_ENDPOINT}/.kibana/dashboard/${fname} -d@$i
    done

   curl -XPOST -f ${ES_ENDPOINT}/.kibana/index-pattern/ecsbeat-*/_update -d '
   {
     "doc": {
        "fieldFormatMap" : "{\"diskSpaceOfflineTotalCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}},\"diskSpaceAllocatedCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}},\"diskSpaceFreeCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}},\"diskSpaceTotalCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}}}"
     }
   }'
