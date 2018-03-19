FROM sd2e/python2:ubuntu16

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

RUN echo $(ls -1 /xplan-api)
RUN echo $(ls -1 /synbiohub_adapter)

# Install xplan-api, sbha, xplan
RUN pip install /xplan_api/xplan_api/

RUN pip install /synbiohub_adapter/synbiohub_adapter/

RUN /xplan_api/xplan_api/get_xplan.sh

COPY init-sd2e.sh /init-sd2e.sh
COPY xplan-rule30-end-to-end-demo.py /xplan-rule30-end-to-end-demo.py
