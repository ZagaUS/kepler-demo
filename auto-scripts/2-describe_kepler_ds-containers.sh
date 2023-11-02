#!/bin/bash

KUBECONFIG=./auto-scripts/microshift-kubeconfig-edge-local

echo "Microshift - Kepler daemonset containers"

kepler_pod=$(oc get pods -n kepler  --output=custom-columns=POD:.metadata.name  --kubeconfig=$KUBECONFIG | grep kepler)

echo $kepler_pod

oc get pods  -o jsonpath='{range .items[*].spec.containers[*]}{.name}{"\n"}{end}'  -n kepler --kubeconfig=$KUBECONFIG