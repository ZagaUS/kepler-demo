# Edge devices power consumption data collection and visualization using kepler.


## Kepler setup in edge device (using RHEL 9.2 running in KVM as edge device)


Download the Red Hat Enterprise Linux 9.2 and
install any virtualization tools (can be, KVM, Virtualbox, VMware or any tool) to setup a RHEL virtual machine.

**Installing and starting the microshift from RPM package**


- Enable the Microshift RPM repository
```
sudo subscription-manager repos \
--enable rhocp-4.14-for-rhel-9-$(uname -m)-rpms \
--enable fast-datapath-for-rhel-9-$(uname -m)-rpms
```

- Install Red Hat build of Microshift
``` 
dnf install -y microshift
```

- Installl greenboot for Red Hat build of Microshift (Optional)
```
sudo dnf install -y microshift-greenboot
```

- Download pull secret from [Red Hat Hybrid Cloud Console](https://console.redhat.com/openshift/install/pull-secret)
```
sudo cp $HOME/openshift-pull-secret /etc/crio/openshift-pull-secret

```
- Make the root user the owner of the /etc/crio/openshift-pull-secret
```
sudo chown root:root /etc/crio/openshift-pull-secret
```

- Make the /etc/crio/openshift-pull-secret file readable and writeable by the root user
```
sudo chmod 600 /etc/crio/openshift-pull-secret
```

- To access the microshift locally, copy the kuebconfig file from the /var/lib/microshift/resources/kubeadmin/kubeconfig and store it in $HOME/.kube folder.

```
mkdir -p ~/.kube/
```

```
sudo cat /var/lib/microshift/resources/kubeadmin/kubeconfig > ~/.kube/config
```

```
chmod go-r ~/.kube/config
```

Follow below steps when firewall-cmd is enabled in RHEL 9.2

- 10.42.0.0/16 is the network range for pods running in microshift and 169.254.169.1 is the IP address of Microshift OVN network
```
sudo firewall-cmd --permanent --zone=trusted --add-source={10.42.0.0/16,169.254.169.1} && sudo firewall-cmd --reload
```

For verification, that microshift is running, Use the following command

```
oc get all -A
```


- To access microshift remotely edit the microshift config file. It'll not be configured, has to be configured maunally.  



```
sudo mv /etc/microshift/config.yaml.default /etc/microshift/config.yaml
```

```
vi /etc/microshift/config.yaml
```

```yaml
dns:
  baseDomain: microshift.example.com
node:
  ...
  ...
apiServer:
  subjectAltNames:
  - edge-microshift.example.com
```


```
sudo systemctl restart microshift
```

- View the kubeconfig file for the newly added subjectAltNames in the folder below

```
cat /var/lib/microshift/resources/kubeadmin/edge-microshift.example.com/kubeconfig
```

use scp to copy this file or copy the content and do the following steps in the remote machine

```
mkdir -p ~/.kube/
```

```
MICROSHIFT_MACHINE=<name or IP address of Red Hat build of MicroShift machine>
```

```
ssh <user>@$MICROSHIFT_MACHINE "sudo cat /var/lib/microshift/resources/kubeadmin/$MICROSHIFT_MACHINE/kubeconfig" > ~/.kube/config
```

```
chmod go-r ~/.kube/config
```

Make sure you have oc client in the remote machine and verify the access to microshift using

```
oc get all -A
```


***Configuring Kepler DaemonSet and enabling power consumption metrics in edge microshift***

- Create namespace in microshift to deploy kepler daemon-set.
```
oc create ns kepler
```

```
oc label ns kepler security.openshift.io/scc.podSecurityLabelSync=false
```


```
oc label ns kepler --overwrite pod-security.kubernetes.io/enforce=privileged
```

- Downloaded the Kepler source code from [kepler - git repo](https://github.com/sustainable-computing-io/kepler) and renamed as edge/edge-kepler. 

```
git clone https://github.com/sustainable-computing-io/kepler.git
```

```
mv ./kepler ./edge/edge-kepler
```

Kepler itself provides the easy way of deploying kepler expoerter as a daemonset in microshift using the [kustomization.yaml](./edge/edge-kepler/manifests/config/exporter/kustomization.yaml)

Since, microshift is a lightweight version of openshift, it requires scc permissions to be added.

Edit the following lines in [kustomization.yaml](./edge/edge-kepler/manifests/config/exporter/kustomization.yaml)

```
vi edge-kepler/manifests/config/exporter/kustomization.yaml
```

     1. Uncomment line 3
       - openshift_scc.yaml

     2. Remove [] in line 8
        patchesStrategicMerge:

     3. uncomment line 18
       - ./patch/patch-openshift.yaml



- Deployed kepler on microshift under the kepler namespace.
```
oc apply --kustomize edge/edge-kepler/manifests/config/base -n kepler
```

Deployed the opentelemetry collector as a side-car container in kepler daemonset.

-  Config file for opentelemetry collector is added as ConfigMap resource 
and created in kepler namespace.
 
Update this file with the opentelemetry hostname and port running in openshift


```yaml  
        exporters:
       logging:
          loglevel: info

       otlp:
        endpoint: http://<opentelemetry-running-in-openshift>:<port>
        tls:
         insecure: true
```

```
vi edge/edge-otel-collector/1-kepler-microshift-otelconfig.yaml
```
```
oc create -n kepler -f edge/edge-otel-collector/1-kepler-microshift-otelconfig.yaml
```

- Added the opemtelemetry as sidecar container with kepler daemonset.

Update the image with any custom opentelemetry collector if necessary or use the default collector image

```
vi edge/edge-otel-collector/2-kepler-patch-sidecar-otel.yaml
```
```
oc patch daemonset kepler-exporter -n kepler --patch-file edge/edge-otel-collector/2-kepler-patch-sidecar-otel.yaml
```

The opentelemetry sidecar attached to the kepler daemonset in microshift is configured to send the data to an external opentelemetry collector running in openshift.

***Data visualization setup in External openshift cluster (Openshift cluster running in remote)***

- Configured the opentelemetry collector using Red Hat OpenShift distributed tracing data collection operator (From openshift Operator Hub).
```
oc apply -f ocp/ocp-otlp_collector/kepler-otel_collector.yaml
```

- Deployed Monitoring Stack to collect prometheus data from the opentelemetry (running in external openshift) using Observability Operator (From openshift Operator Hub).
```
oc apply -f ocp/ocp-prometheus/kepler-prometheus-monitoringstack.yaml
```

- Deployed grafana Dashboard to visualize the data collected in the Prometheus Monitoring Stack.
```
oc apply -f ocp/ocp-grafana/1-grafana-kepler.yaml
``` 
```
oc apply -f ocp/ocp-grafana/2-grafana-datasource-kepler.yaml
```

```
oc apply -f ocp/ocp-grafana/3-grafana-dashboard-kepler.yaml
```



***References*** 

https://github.com/sustainable-computing-io/kepler


https://github.com/redhat-et/edge-ocp-observability


https://github.com/openshift/microshift/blob/main/docs/contributor/network/ovn_kubernetes_traffic_flows.md