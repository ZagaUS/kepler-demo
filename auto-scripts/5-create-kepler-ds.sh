#!/bin/bash

KUBECONFIG=./auto-scripts/microshift-kubeconfig-edge-local

oc apply -k ./edge/edge-kepler --kubeconfig=$KUBECONFIG 