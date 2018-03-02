FROM sd2e/base:ubuntu16

# Copied from https://github.com/SD2E/reactors-etl/blob/master/build/admin/docker/python2/Dockerfile.ubuntu16
RUN apt-get -y update && \
    apt-get -y install build-essential \
               python python-dev \
               python-pip \
               python-setuptools \
               libssl-dev \
               libffi-dev  && \
    apt-get clean

# Update python infrastructure
RUN pip install --upgrade pip && \
    pip install --upgrade virtualenv

# Install SD2E dependencies
RUN curl -L https://raw.githubusercontent.com/sd2e/sd2e-cli/master/install/install.sh | sh && \
    tail ~/.bashrc
RUN pip install git+https://github.com/TACC/agavepy.git#egg=agavepy

# Install xplan-api to drive xplan app
RUN pip install git+https://github.com/SD2E/xplan_api.git

COPY init-sd2e.sh /init-sd2e.sh
COPY xplan-rule30-end-to-end-demo.py /xplan-rule30-end-to-end-demo.py

RUN ls -l /
