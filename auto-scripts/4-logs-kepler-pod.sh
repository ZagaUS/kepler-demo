#!/bin/bash

KUBECONFIG=./auto-scripts/microshift-kubeconfig-edge-local

echo "Microshift - Kepler pod log"

kepler_pod=$(oc get pods -n kepler  --output=custom-columns=POD:.metadata.name  --kubeconfig=$KUBECONFIG | grep kepler)

echo $kepler_pod

oc logs -f $kepler_pod -n kepler --kubeconfig=$KUBECONFIG
