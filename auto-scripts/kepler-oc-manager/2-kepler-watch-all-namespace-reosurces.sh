#!/bin/bash

KUBECONFIG=./auto-scripts/kubeconfig/microshift-kubeconfig-edge-local

echo "Microshift - Kepler namespace resources status watch"

watch -n 2 oc get all -n kepler --kubeconfig=$KUBECONFIG