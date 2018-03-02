FROM sd2e/reactor-base:python2

RUN pip install git+https://github.com/SD2E/xplan_api.git

COPY init-sd2e.sh /init-sd2e.sh
COPY  xplan-rule30-end-to-end-demo.py /xplan-rule30-end-to-end-demo.py
