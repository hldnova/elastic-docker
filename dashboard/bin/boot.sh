#!/bin/bash
########################################################################
# Boot script gets executed whenever the container is created
# Use this script to install/configure any bits on the container
########################################################################

BOOT_LOCATION=${BOOT_LOCATION:-'.'}

source ${BOOT_LOCATION}/boot_lib.sh

log "############################### boot operation begin ############################"

# a replacement for systems, that don't have "which" command
log "checking 'which' command"
type which || { 
  log "which not found - setting up a replacement"
  alias which=_which
  echo ". ${BOOT_LOCATION}/boot_lib.sh" >> /etc/bash.bashrc
  echo 'alias which=_which' >> /etc/bash.bashrc
  type which
}

set -uex

log "Verify environment"

_validate_environment

log "All validations are complete. Going ahead with the configuration steps."

log "Enable dynamic mappings"

_enable_dynamic_mapping

log "Create templates"

_create_navigation_template

_create_navigation_category

_create_accesslog_template

_create_metricbeat_template

_create_ecsbeat_template

_create_ecsbeat_template_extra

log "Create indexes"

_create_accesslog_kibana_index

_create_metricbeat_kibana_index

_create_ecsbeat_kibana_index

_create_navigation_kibana_index

log "Load dashboards"

_import_kibana_visualization

_import_kibana_search

_import_kibana_dashboard

_set_kibana_default_index

#log "Create ecsbeat Kibana field format map"

#_create_ecsbeat_field_format_map

