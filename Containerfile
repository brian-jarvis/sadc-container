FROM  registry.redhat.io/ubi8/ubi-minimal:8.5

RUN microdnf  install --disableplugin=subscription-manager --enablerepo=rhel-8-for-x86_64-appstream-rpms sysstat && microdnf clean all

LABEL version="8.5"

#labels for container catalog
LABEL summary="A containerized version of the sysstat data collection utility, which collects system-level performance metrics on Red Hat Enterpise Linux CoreOS Host. The container leverages the atomic command for installation, activation and management."
LABEL description="The sadc command samples system data at specified intervals and writes in binary format to the specified outfile or to standard output."
