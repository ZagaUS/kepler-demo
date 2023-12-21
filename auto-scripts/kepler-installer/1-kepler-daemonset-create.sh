#!/bin/bash

KUBECONFIG=./auto-scripts/kubeconfig/microshift-kubeconfig-edge-local

oc apply -k ./edge/edge-kepler --kubeconfig=$KUBECONFIG 