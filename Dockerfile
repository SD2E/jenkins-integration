FROM sd2e/python2:ubuntu16

# steel bank common lisp
RUN apt-get -y install sbcl

# Install SD2E CLI
RUN curl -L \
    https://raw.githubusercontent.com/sd2e/sd2e-cli/master/sd2e-cloud-cli.tgz \
    -o /tmp/sd2e-cloud-cli.tgz \
    && tar xzf /tmp/sd2e-cloud-cli.tgz -C /usr/local \
    && rm /tmp/sd2e-cloud-cli.tgz \
    && ln -s /usr/local/sd2e-cloud-cli/bin/* /usr/local/bin/

# Give the user a place to store the sd2e cli creds
RUN mkdir -p /.agave && \
    chmod 0777 /.agave

COPY xplan_api /xplan_api
COPY synbiohub_adapter /synbiohub_adapter

# Install xplan-api, sbha, xplan
RUN pip install /xplan_api/

# This is not supported yet
#RUN pip install /synbiohub_adapter

#xplan setup
RUN mkdir -p /xplan
RUN /xplan_api/get_xplan.sh /xplan

RUN cd /xplan_api && pytest

# change YG when merged
RUN cd /xplan/xplan && git checkout yeast_gates
RUN export XPLAN_PATH=/xplan/xplan

#COPY init-sd2e.sh /init-sd2e.sh
#COPY xplan-rule30-end-to-end-demo.py /xplan-rule30-end-to-end-demo.py

RUN cd /xplan_api
RUN python /xplan_api/example/yeast_gates_doe_biofab.py

RUN ls -1 .