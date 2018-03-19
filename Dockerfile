FROM sd2e/python2:ubuntu16

# steel bank common lisp
RUN apt-get -y install sbcl
RUN apt-get -y install subversion

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

# for testing, xplan_api
RUN pip install pytest
RUN pip install sexpdata
RUN pip install jsondiff

# Install xplan-api, sbha, xplan
RUN pip install /xplan_api/

# This is not supported yet
#RUN pip install /synbiohub_adapter

#xplan setup
RUN mkdir -p /xplan

#comment out this line, remove when fixed
#RUN sed -i '/(cd xplan; git checkout yeast_gates)/ s/^/#/' /xplan_api/get_xplan.sh

RUN /xplan_api/get_xplan.sh /xplan

RUN pip list

RUN cd /xplan_api && python -m pytest

# change YG when merged
RUN cd /xplan/xplan && git checkout yeast_gates
ENV XPLAN_PATH=/xplan/xplan

#COPY init-sd2e.sh /init-sd2e.sh
#COPY xplan-rule30-end-to-end-demo.py /xplan-rule30-end-to-end-demo.py

RUN cd /xplan_api
RUN python /xplan_api/example/yeast_gates_doe_biofab.py

RUN ls -1 .