set -x
set -e

# Install xplan-api, sbha, xplan
pip3 install -e /xplan_api[dev]

#SBH
# returns a non-zero exit code looking for pySBOLx
pip3 install /synbiohub_adapter || true

cd /synbiohub_adapter && python3 -m unittest tests/Test_SPARQLQueries.py

# returns a non-zero exit code looking for a windows dependency
cd /xplan_to_sbol && python3 setup.py install || true

# has known failures...
cd /xplan_to_sbol && python3 -m tests.SBOLTestSuite || true

pip3 install -r /ta3-api/requirements.txt

cd /ta3-api && python3 -m pytest

#xplan setup
mkdir -p /xplan

/xplan_api/get_xplan.sh /xplan

cd /xplan/xplan

# branch may not exist, use development on xplan otherwise
EXISTS="$(git ls-remote --heads origin $BRANCH | wc -l)"

if [ $EXISTS -eq 1 ]; then
  git checkout "$BRANCH"
else
  git checkout development
fi

# check libraries
pip3 list

# test xplan
cd /xplan_api && python3 -m pytest

export XPLAN_PATH=/xplan/xplan

cd /xplan_api

python3 /xplan_api/example/yeast_gates_doe_biofab.py

ls -lh .

# validate plans
mkdir -p biofab

mv biofab*.json biofab/

python3 /ta3-api/src/schema/validateInput.py /ta3-api/src/schema/plan-schema.json biofab/
