#!/bin/bash

KUBECONFIG=./auto-scripts/microshift-kubeconfig-edge-local

echo "Microshift - Kepler namespace info"

watch -n 2 oc get all -n kepler --kubeconfig=$KUBECONFIG