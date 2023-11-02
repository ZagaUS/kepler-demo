#!/bin/bash

KUBECONFIG=./auto-scripts/microshift-kubeconfig-edge-local


echo "Microshift - Kepler pods info"

watch -n 2 oc get pods -n kepler --kubeconfig=$KUBECONFIG