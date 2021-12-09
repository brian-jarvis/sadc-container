Red Hat CoreOS does not include the sysstat package for running performance tools against a node.

This repo contains the ingredients to run sysstat to collect sars data as was done for Atomic RHEL nodes.

## Setup building host with subscriptions
In order to build the container we need to have RH subscriptions available.  If you are on a RHEL host you likely
already have these in place.  If you are using Fedora or building in OpenShift these will not be there.

reference: https://puiterwijk.org/posts/rhel-containers-on-non-rhel-hosts/

You can mount the entitlement certificates downloaded from access.redhat.com into the build at /run/secrets.

Make sure you get the correct entitlement certificate.  

I also had to change the rhsm.conf file as below to match where the certs are placed as shown below.  It is possible 
this isn't actually needed and something else is configured incorrectly.
  ```
  # Server CA certificate location:
  # ca_cert_dir = /etc/rhsm/ca/
  ca_cert_dir = /etc/rhsm-host/ca/

  # Default CA cert to use when generating yum repo configs:
  repo_ca_cert = %(ca_cert_dir)sredhat-uep.pem

  # Where the certificates should be stored
  # productCertDir = /etc/pki/product
  productCertDir = /etc/pki/product-default

  # entitlementCertDir = /etc/pki/entitlement
  entitlementCertDir = /etc/pki/entitlement-host
  ```

On the host I placed the entitlement certs in  /var/usr/share/rhel/

## Build image
Run the below command to build the image.
  ```
  sudo podman build --authfile /home/bjarvis/z_work/moodys/discon/rh_pull  -v /var/usr/share/rhel/secrets:/run/secrets:Z -v ${PWD}/redhat.repo:/etc/yum.repos.d/sadc.repo:Z --file ./Containerfile  --tag quay.io/bjarvis/sadc-container:8.5 .
  ```

And push to your registry
```
sudo podman push --authfile /home/bjarvis/bjarvis_quay_auth  quay.io/bjarvis/sadc-container:8.5
```

## Running the image
Deploying the service with 
  ```
  oc create -f ./deployment/
  ```

After deploying, each pod will ensure the node has the required file paths.  The main container loops on a timescale as defined in
the datemonset env `sadc-frequency`.  Currently this is set to 10m which is the default timer for RHEL sysstat service.

## reviewing data
The data is stored on the node at /var/log/sa.  The file is rotated daily.  To read the data you can run a command like below.
```
## find the pod on the node
NODENAME=vst2osif02.vst.bry.tamlab.rdu2.redhat.com
POD_SEL='oc get pod -A -l app=sadc-collector --field-selector spec.nodeName=$NODENAME -o name'

## get ALL data
oc -n node-performance-monitoring exec $(eval $POD_SEL) --  sar -A

## get CPU data
oc -n node-performance-monitoring exec $(eval $POD_SEL) --  sar -u
```
