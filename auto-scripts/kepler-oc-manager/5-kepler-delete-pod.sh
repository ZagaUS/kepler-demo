#!/bin/bash

KUBECONFIG=./auto-scripts/kubeconfig/microshift-kubeconfig-edge-local

kepler_pod=$(oc get pods -n kepler  --output=custom-columns=POD:.metadata.name   | grep kepler)

echo "Microshift - Kepler pod delete"
echo ""
echo "Deleting..." $kepler_pod

oc delete pod/$kepler_pod -n kepler