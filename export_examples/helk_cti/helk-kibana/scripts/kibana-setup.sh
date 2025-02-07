#!/bin/bash

# HELK script: kibana-setup.sh
# HELK script description: Creates Kibana index patterns, dashboards and visualizations automatically.
# HELK build version: 0.9 (Alpha)
# Author:
# License: BSD 3-Clause

# References: 
# https://github.com/elastic/kibana/issues/3709 (https://github.com/hobti01)
# https://explainshell.com/explain?cmd=set+-euxo%20pipefail
# https://github.com/elastic/beats-dashboards/blob/master/load.sh
# https://github.com/elastic/kibana/issues/14872
# https://github.com/elastic/stack-docker/blob/master/docker-compose.yml

# *********** Setting Variables ***************
KIBANA="helk-kibana:5601"
#TIME_FIELD="@timestamp"
DEFAULT_INDEX="mitre-attack-*"
DIR=/usr/share/kibana/dashboards

# *********** Setting Index Pattern Array ***************
declare -a index_patterns=("mitre-attack-*")

# *********** Waiting for Kibana to be available ***************
echo "[++] Checking to see if kibana is up..."
until curl -v helk-kibana:5601 -o /dev/null; do
    sleep 1
done

# *********** Creating Kibana index-patterns ***************
echo "[++] Creating Kibana Index Patterns..."
for index in ${!index_patterns[@]}; do 
    curl -f -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: anything" \
    "$KIBANA/api/saved_objects/index-pattern/${index_patterns[${index}]}" \
    -d"{\"attributes\":{\"title\":\"${index_patterns[${index}]}\"}}"
done

# *********** Loading dashboards ***************
echo "[++] Loading Dashboards..."
for file in ${DIR}/*.json
do  
    curl -XPOST "$KIBANA/api/kibana/dashboards/import" -H 'kbn-xsrf:true' \
    -H 'Content-type:application/json' -d @${file} || exit 1
done