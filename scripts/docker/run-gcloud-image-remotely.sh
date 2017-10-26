#!/usr/bin/env bash

##
# Copyright 2017 Google Inc. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

set -e
set -x

cd "`dirname ${BASH_SOURCE[0]}`"

PRS=(1469 1485 1484)
AUTHORS=(iamJoeTaylor bonniezhou kfranqueiro)
REMOTE_URLS=(https://github.com/iamJoeTaylor/material-components-web.git https://github.com/material-components/material-components-web.git https://github.com/material-components/material-components-web.git)
REMOTE_BRANCHES=(joetaylor/issue-1435-textfield-hightlight-color rename-textfield fix/slider-up-events)

CLUSTER=pr-demo-cluster-test

for i in `seq 1 1 3`; do
  # Create a cluster of server instances
  gcloud container clusters create "${CLUSTER}-${i}" --num-nodes=1
#  gcloud container clusters get-credentials "${CLUSTER}-${i}"

  # Deploy the application and create 1 pod with 1 cluster
  kubectl run "${CLUSTER}-${i}" --image=us.gcr.io/material-components-web/dev-server:latest --port 8080 -- --pr "${PRS[$i]}" --author "${AUTHORS[$i]}" --remote-url "${REMOTE_URLS[$i]}" --remote-branch "${REMOTE_BRANCHES[$i]}"

  # Expose the server to the internet
  kubectl expose deployment "${CLUSTER}-${i}" --type=LoadBalancer --port 80 --target-port 8080

  IP_ADDR=`kubectl get service | grep -E -e "^${CLUSTER} " | awk '{ print $3 }'`
  echo "${CLUSTER}: ${IP_ADDR}"
done

set +x
