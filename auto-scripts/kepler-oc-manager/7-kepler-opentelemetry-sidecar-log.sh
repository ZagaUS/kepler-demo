#!/bin/bash

KUBECONFIG=./auto-scripts/kubeconfig/microshift-kubeconfig-edge-local

kepler_pod=$(oc get pods -n kepler  --output=custom-columns=POD:.metadata.name  --kubeconfig=$KUBECONFIG | grep kepler)

echo "Microshift - Kepler exporter - kepler opentelemetry sidecar log"
echo ""
echo "Kepler container log from : $kepler_pod"

oc logs -f $kepler_pod -c otc-container -n kepler --kubeconfig=$KUBECONFIG