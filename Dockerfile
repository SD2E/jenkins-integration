FROM sd2e/python3:ubuntu17

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
COPY ta3-api /ta3-api
COPY xplan_to_sbol /xplan_to_sbol

# for testing, xplan_api
RUN pip3 install pytest
RUN pip3 install sexpdata
RUN pip3 install jsondiff

# Install xplan-api, sbha, xplan
RUN pip3 install /xplan_api/

# This is not supported yet...
#RUN pip3 install /synbiohub_adapter

# custom wheel for python3.6
RUN pip3 install https://github.com/tcmitchell/pySBOL/blob/ubuntu/Ubuntu_16.04_64_3/dist/pySBOL-2.3.0.post11-cp36-none-any.whl?raw=true

# returns a non-zero exit code looking for a windows dependency
RUN cd /xplan_to_sbol && python3 setup.py install || true

RUN cd /xplan_to_sbol && python3 -m tests.SBOLTestSuite || true

RUN pip3 install -r /ta3-api/requirements.txt

#xplan setup
RUN mkdir -p /xplan

RUN /xplan_api/get_xplan.sh /xplan

# check libraries
RUN pip3 list

# test xplan
RUN cd /xplan_api && python3 -m pytest

ENV XPLAN_PATH=/xplan/xplan

#COPY init-sd2e.sh /init-sd2e.sh
#COPY xplan-rule30-end-to-end-demo.py /xplan-rule30-end-to-end-demo.py

RUN cd /xplan_api
RUN python3 /xplan_api/example/yeast_gates_doe_biofab.py

RUN ls -1 .

# validate plans
RUN mkdir -p biofab

RUN mv biofab*.json biofab/

RUN python3 /ta3-api/src/schema/validateInput.py /ta3-api/src/schema/plan-schema.json biofab/