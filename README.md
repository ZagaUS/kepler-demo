# Edge devices power consumption data collection and visualization using kepler.


## Kepler setup

**Manual setup**

***kepler setup in edge device (using RHEL9.2 running in KVM as edge device)***

- 
```
    sudo subscription-manager repos \
    --enable rhocp-4.14-for-rhel-9-$(uname -m)-rpms \
    --enable fast-datapath-for-rhel-9-$(uname -m)-rpms
```

- 
``` 
dnf install -y microshift
```
- 
```
sudo cp $HOME/openshift-pull-secret /etc/crio/openshift-pull-secret
```
- 
```
sudo chown root:root /etc/crio/openshift-pull-secret
```
- 
```
sudo chmod 600 /etc/crio/openshift-pull-secret
```
- 
```
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16
```

- 
```
sudo firewall-cmd --permanent --zone=trusted --add-source=169.254.169.1
```

-
``` 
sudo firewall-cmd --reload
```

- 
```
oc create ns kepler
```

- 
```
oc label ns kepler security.openshift.io/scc.podSecurityLabelSync=false
```
- 
```
oc label ns kepler --overwrite pod-security.kubernetes.io/enforce=privileged
```

- 
```
vi edge-kepler/manifests/config/exporter/kustomization.yaml
```

- 
```
oc apply --kustomize edge/edge-kepler/manifests/config/base -n kepler
```

- 
```
vi edge/edge-otel-collector/1-kepler-microshift-otelconfig.yaml
```

- 
```
oc create -n kepler -f edge/edge-otel-collector/1-kepler-microshift-otelconfig.yaml
```

- 
```
vi edge/edge-otel-collector/2-kepler-patch-sidecar-otel.config.yaml
```

- 
```
oc patch daemonset kepler-exporter -n kepler --patch-file edge/edge-otel-collector/2-kepler-patch-sidecar-otel.yaml
```

***Data visualization setup in External openshift cluster (Openshift cluster running in remote)***

- 
```
oc apply -f ocp/ocp-otlp_collector/kepler-otel_collector.yaml
```

- 
```
oc apply -f ocp/ocp-prometheus/kepler-prometheus-remotewrite.yaml
```

- 
```
oc apply -f ocp/ocp-grafana/1-grafana-kepler.yaml
```
- 
```
oc apply -f ocp/ocp-grafana/2-grafana-datasource-kepler.yaml
```

- 
```
oc apply -f ocp/ocp-grafana/3-grafana-dashboard-kepler.yaml
```


**Auto setup**

Work in progress
