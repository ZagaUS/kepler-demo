#!/bin/bash

KUBECONFIG=./auto-scripts/kubeconfig/microshift-kubeconfig-edge-local


echo "Microshift - Kepler pods status watch"

watch -n 2 oc get pods -n kepler --kubeconfig=$KUBECONFIG