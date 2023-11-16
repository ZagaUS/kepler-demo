#!/bin/bash

KUBECONFIG=./auto-scripts/microshift-kubeconfig-edge-local

echo "1 kepler Namespace"
echo "------------------"
oc get daemonset kepler-exporter-ds -n kepler -o yaml --kubeconfig=$KUBECONFIG 

echo " "
echo "================================================================================"
echo "================================================================================"

echo " "
echo "2 kepler ConfigMap"
echo "------------------"
oc get configmap kepler-exporter-cm -n kepler -o yaml --kubeconfig=$KUBECONFIG 

echo " "
echo "================================================================================"
echo "================================================================================"

echo " "
echo "3 kepler Namespace"
echo "------------------"
oc get sa kepler-exporter-sa -n kepler -o yaml --kubeconfig=$KUBECONFIG 

echo " "
echo "================================================================================"
echo "================================================================================"
echo " "

echo "4 kepler Cluster Role"
echo "------------------"
oc get clusterrole kepler-exporter-cr -n kepler -o yaml --kubeconfig=$KUBECONFIG 

echo " "
echo "================================================================================"
echo "================================================================================"
echo " "

echo "5 kepler Cluster Role Binding"
echo "------------------"
oc get clusterrolebinding kepler-exporter-crb -n kepler -o yaml --kubeconfig=$KUBECONFIG 

echo " "
echo "================================================================================"
echo "================================================================================"
echo " "

echo "6 Kepler security context constraints"
echo "------------------"
oc get securitycontextconstraints kepler-exporter-scc -n kepler -o yaml --kubeconfig=$KUBECONFIG 


echo " "
echo "================================================================================"
echo "================================================================================"
echo " "

echo "7 Kepler service"
echo "------------------"
oc get service kepler-exporter-svc -n kepler -o yaml --kubeconfig=$KUBECONFIG 

echo " "
echo "================================================================================"
echo "================================================================================"
echo " "

echo "8 kepler DaemonSet"
echo "------------------"
oc get ds kepler-exporter-ds -n kepler -o yaml --kubeconfig=$KUBECONFIG 
