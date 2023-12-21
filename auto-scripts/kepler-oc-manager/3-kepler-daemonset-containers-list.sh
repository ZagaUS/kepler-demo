#!/bin/bash

KUBECONFIG=./auto-scripts/kubeconfig/microshift-kubeconfig-edge-local

echo "Microshift - Kepler daemonset containers list"

kepler_pod=$(oc get pods -n kepler  --output=custom-columns=POD:.metadata.name  --kubeconfig=$KUBECONFIG | grep kepler)

echo "List of containers in pod : $kepler_pod"
echo ""
echo "Available Containers in $kepler_pod :"
oc get pods $kepler_pod -o jsonpath='{range .items[*].spec.containers[*]}{.name}{"\n"}{end}'  -n kepler --kubeconfig=$KUBECONFIG