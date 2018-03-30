FROM sd2e/python3:ubuntu17

RUN apt-get update

# for xplan_to_sbol
RUN apt-get -y install libxslt1-dev

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

# for testing, xplan_api
RUN pip3 install pytest
RUN pip3 install sexpdata
RUN pip3 install jsondiff

#python 3 fork
RUN pip3 install --upgrade git+https://github.com/willblatt/pyDOE

# custom wheel for python3.6
RUN pip3 install https://github.com/tcmitchell/pySBOL/blob/ubuntu/Ubuntu_16.04_64_3/dist/pySBOL-2.3.0.post11-cp36-none-any.whl?raw=true

WORKDIR /

ADD run.sh /run.sh

CMD /run.sh