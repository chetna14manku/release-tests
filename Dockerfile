FROM quay.io/fedora/fedora:38

RUN dnf update -y &&\
    dnf install -y go wget unzip

ENV OC_VERSION=4.13
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast-${OC_VERSION}/openshift-client-linux.tar.gz \
    -O /tmp/openshift-client.tar.gz &&\
    tar xzf /tmp/openshift-client.tar.gz -C /usr/bin oc &&\
    rm /tmp/openshift-client.tar.gz

ENV TKN_VERSION=1.10.0
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/pipelines/${TKN_VERSION}/tkn-linux-amd64.tar.gz \
   -O /tmp/tkn.tar.gz &&\
   tar xzf /tmp/tkn.tar.gz -C /usr/bin --no-same-owner tkn tkn-pac opc &&\
   rm /tmp/tkn.tar.gz

ENV GAUGE_VERSION=1.5.1
ENV GAUGE_HOME=/root/.gauge
RUN wget https://github.com/getgauge/gauge/releases/download/v${GAUGE_VERSION}/gauge-${GAUGE_VERSION}-linux.x86_64.zip \
    -O /tmp/gauge.zip &&\
    unzip /tmp/gauge.zip gauge -d /usr/bin &&\
    rm /tmp/gauge.zip &&\
    gauge install go &&\
    gauge install html-report &&\
    gauge install screenshot &&\
    gauge install xml-report &&\
    gauge config check_updates false &&\
    gauge config runner_connection_timeout 600000 && \
    gauge config runner_request_timeout 300000 &&\
    go env -w GOPROXY="https://proxy.golang.org,direct"

# Copy the tests into /tmp/release-tests
RUN mkdir /tmp/release-tests
WORKDIR /tmp/release-tests
COPY . .

# Set required permissions for OpenShift usage
RUN chgrp -R 0 /tmp && \
    chmod -R g=u /tmp

CMD ["/bin/bash"]