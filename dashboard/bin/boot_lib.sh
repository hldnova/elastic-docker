#!/bin/sh
########################################################################
# Boot script gets executed whenever the container is created
# Use this script to install/configure any bits on the container
# This script file should be available under /vipr-share folder
# in the host machine and the folder will be visible to the container
########################################################################

set -u
export PATH=/bin:/bin:/sbin:/usr/bin:/usr/sbin

SHARED_LOGS_VOLUME='.'
LOG_FILE=${SHARED_LOGS_VOLUME}/boot.log
INSTALL_BASE='/opt/emc/nautilus/controller'
DASHBOARD_BASE=${BOOT_LOCATION}/../
VISUALIZATION_PATH=${DASHBOARD_BASE}/visualization
SEARCH_PATH=${DASHBOARD_BASE}/search
DASHBOARD_PATH=${DASHBOARD_BASE}/dashboard
TEMPLATE_PATH=${BOOT_LOCATION}/../template-index
NAVIGATION_INDEX=navigation
ES_ENDPOINT=${ES_ENDPOINT:-http://localhost:9200}

log(){
    msg=" $*"
    echo $(date "+%m%d%Y %T") : $msg
    echo $(date "+%m%d%Y %T"):  $msg >> ${LOG_FILE}
}

_fatal() {
    #set +Ex
    #echo "$0: Error: $*" >&2
    exit 1
}

# a replacement for systems, that don't have "which" command
_which() {
    local bin="$1"
    echo $PATH| tr ':' '\n'| while read dir; do
      if [ -x "$dir/$bin" ] ; then
          echo "$dir/$bin"
          return 0
      fi
    done
    echo "$bin not found"
    return 1                                                                                                                                                                   
}  

# validate ES is reachable
_validate_environment() {
    log "validate if ES is reachable"
}

_enable_dynamic_mapping() {
    curl -f -XPUT ${ES_ENDPOINT}/_template/enable_dynamic_mappings -d '
    {
      "order": 0,
      "template": "*",
      "mappings": {
         "_default_": {
             "numeric_detection": true
         }
      } 
    }'
    if [ 0 -eq $? ]; then
       log "enable dynamic mapping successfully"
    else
       log "failed to enable dynamic mapping"
    fi
}

# create template for general navigation
_create_navigation_template() {
    log "create template for navigation"
    curl -f -XPUT ${ES_ENDPOINT}/_template/navigation -d@${TEMPLATE_PATH}/navigation_template.json
    if [ 0 -eq $? ]; then
       log "create template for navigation successfully"
    else
       log "failed to create template for navigation"
    fi
}

# create navigation category
_create_navigation_category() {
    log "create navigation category"
    curl -f -XPUT ${ES_ENDPOINT}/_bulk  --data-binary @${TEMPLATE_PATH}/navigation_category.json
    if [ 0 -eq $? ]; then
       log "created navigation category successfully"
    else
       log "failed to create navigation category"
    fi
}

# create template for accesslog 
_create_accesslog_template() {
    log "create template for accesslog"
    curl -f -XPUT ${ES_ENDPOINT}/_template/accesslog -d@${TEMPLATE_PATH}/accesslog_template.json
    if [ 0 -eq $? ]; then
       log "create template for accesslog successfully"
    else
       log "failed to create template for accesslog"
    fi
}

# create template for metricbeat
_create_metricbeat_template() {
    log "create template for metricbeat"
    curl -f -XPUT ${ES_ENDPOINT}/_template/metricbeat -d@${TEMPLATE_PATH}/metricbeat_template.json
    if [ 0 -eq $? ]; then
       log "create template for metricbeat successfully"
    else
       log "failed to create template for metricbeat"
    fi
}

# create template for ecsbeat
_create_ecsbeat_template() {
    log "create template for ecsbeat"
    curl -f -XPUT ${ES_ENDPOINT}/_template/ecsbeat -d@${TEMPLATE_PATH}/ecsbeat_template.json
    if [ 0 -eq $? ]; then
       log "create template for ecsbeat successfully"
    else
       log "failed to create template for ecsbeat"
    fi
}

_create_ecsbeat_template_extra() {
    log "create extra template for ecsbeat"
    curl -f -XPUT ${ES_ENDPOINT}/_template/ecsbeat-extra -d@${TEMPLATE_PATH}/ecsbeat_template_extra.json
    if [ 0 -eq $? ]; then
       log "create extra template for ecsbeat successfully"
    else
       log "failed to create extra template for ecsbeat"
    fi
}

_create_accesslog_kibana_index() {
    log "create index for accesslog"
    curl -f -XPUT ${ES_ENDPOINT}/.kibana/index-pattern/filebeat-* -d@${TEMPLATE_PATH}/filebeat_field_update.data
    if [ 0 -eq $? ]; then
       log "create kibana index for filebeat successfully"
    else
       log "failed to create kibana index for filebeat"
    fi
}

_create_metricbeat_kibana_index() {
    log "create index for metricbeat"
    curl -f -XPUT ${ES_ENDPOINT}/.kibana/index-pattern/metricbeat-* -d@${TEMPLATE_PATH}/metricbeat_field_update.data
    if [ 0 -eq $? ]; then
       log "create kibana index for metricbeat successfully"
    else
       log "failed to create kibana index for metricbeat"
    fi
}

_create_ecsbeat_kibana_index() {
    log "create index for ecsbeat"
    curl -f -XPUT ${ES_ENDPOINT}/.kibana/index-pattern/ecsbeat-* -d@${TEMPLATE_PATH}/ecsbeat_field_update.data
    if [ 0 -eq $? ]; then
       log "create kibana index for ecsbeat successfully"
    else
       log "failed to create kibana index for ecsbeat"
    fi
}

_create_navigation_kibana_index() {
    log "create index for navigation"
    curl -f -XPUT ${ES_ENDPOINT}/.kibana/index-pattern/navigation -d@${TEMPLATE_PATH}/navigation_field_update.data
    if [ 0 -eq $? ]; then
       log "create kibana index for navigation successfully"
    else
       log "failed to create kibana index for navigation"
    fi
}

_create_elastalert_kibana_index() {
    log "create index for navigation"
    curl -f -XPUT ${ES_ENDPOINT}/.kibana/index-pattern/elastalert_status -d@${TEMPLATE_PATH}/elastalert_field_update.data
    if [ 0 -eq $? ]; then
       log "create kibana index for elastalert successfully"
    else
       log "failed to create kibana index for elastalert"
    fi
}

_set_kibana_default_index() {
    log "set kibana default index"
    curl -f -XPUT ${ES_ENDPOINT}/.kibana/config/5.1.2 -d '{"defaultIndex" : "filebeat-*"}'
    if [ 0 -eq $? ]; then
       log "set kibana default index successfully"
    else
       log "failed to kibana default index for navigation"
    fi
}

_import_kibana_visualization() {
    log "import kibana visualization"
    cd ${VISUALIZATION_PATH}
    for i in `ls -1`; do 
        local fname=`basename $i .json`
        curl -f -XPUT ${ES_ENDPOINT}/.kibana/visualization/${fname} -d@$i
        if [ 0 -ne $? ]; then
          log "failed to import kibana visualization"
          return
        fi
    done
    log "import kibana visualization successfully"
}

_import_kibana_search() {
    log "import kibana search"
    cd ${SEARCH_PATH}
    for i in `ls -1`; do 
        local fname=`basename $i .json`
        curl -f -XPUT ${ES_ENDPOINT}/.kibana/search/${fname} -d@$i
        if [ 0 -ne $? ]; then
          log "failed to import kibana search"
          return
        fi
    done
    log "import kibana search successfully"
}

_import_kibana_dashboard() {
    log "import kibana dashboard"
    cd ${DASHBOARD_PATH}
    for i in `ls -1`; do 
        local fname=`basename $i .json`
        curl -f -XPUT ${ES_ENDPOINT}/.kibana/dashboard/${fname} -d@$i
        if [ 0 -ne $? ]; then
          log "failed to import kibana dashboard"
          return
        fi
    done
    log "import kibana dashboard successfully"
}

#_create_ecsbeat_field_format_map() {
#   curl -f -XPOST ${ES_ENDPOINT}/.kibana/index-pattern/ecsbeat-*/_update -d '
#   {
#     "doc": {
#        "fieldFormatMap" : "{\"diskSpaceOfflineTotalCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}},\"diskSpaceAllocatedCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}},\"diskSpaceFreeCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}},\"diskSpaceTotalCurrent_Space\":{\"id\":\"bytes\",\"params\":{\"pattern\":\"0,0b\"}}}"
#     }
#   }'
#   if [ 0 -eq $? ]; then
#     log "create ecsbeat field format map successfully"
#   else
#     log "failed to create ecsbeat field format map"
#   fi 
#}
