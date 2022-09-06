FROM debian:buster

RUN apt-get update \
  && apt-get -y install default-jre-headless \
  vim \
  make \
  openssh-client \
  python3

RUN apt-get -y install python3-pip \
  && pip3 install --upgrade pip \
  && pip3 install debugpy

ARG NSO_INSTALL_FILE

COPY nso-install-files/$NSO_INSTALL_FILE /tmp

RUN groupadd ncsadmin -g 1001 \
  && useradd -s /bin/bash -c "NSO runtime user" -mN -g ncsadmin -u 1001 nsoadmin \
  && sh /tmp/$NSO_INSTALL_FILE --system-install --run-as-user nsoadmin \
  && cp /etc/ncs/ncs.conf /etc/ncs/ncs.conf.orig \
  && cp /opt/ncs/current/bin/ncs-start-python-vm /opt/ncs/current/bin/ncs-start-python-vm.orig

ARG DEBUG_PACKAGE
ENV DEBUG_PACKAGE=$DEBUG_PACKAGE

COPY /scripts/ncs-start-python-vm /opt/ncs/current/bin/ncs-start-python-vm

COPY requirements.txt nso_config.xml /tmp/

RUN pip3 install -r /tmp/requirements.txt \
  && apt-get -y purge python3-pip

ADD packages/ /var/opt/ncs/packages

RUN . /opt/ncs/current/ncsrc \
  && for d in /var/opt/ncs/packages/*/; do make all -C $d/src; done

EXPOSE 2024 8080 8888 5678

ENTRYPOINT /bin/bash
