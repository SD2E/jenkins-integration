set -x
set -e

UNDER_CI=0
CI_PLATFORM=
CI_UID=$(id -u ${USER})
CI_GID=$(id -g ${USER})

if [ ! -z "${JENKINS_URL}" ]; then
  UNDER_CI=1
  CI_PLATFORM="Jenkins"
  CI_UID=$(id -u jenkins)
  CI_GID=$(id -g jenkins)
fi

MOUNTS="-v $(pwd)/xplan_api:/xplan_api -v $(pwd)/ta3-api:/ta3-api -v $(pwd)/xplan_to_sbol:/xplan_to_sbol -v $(pwd)/synbiohub_adapter:/synbiohub_adapter"

if ((UNDER_CI)); then
  # If running a Dockerized process with a volume mount
  # written files will be owned by root and unwriteable by
  # the CI user. We resolve this by setting the group, which
  # is the same approach we use in the container runner
  # that powers container-powered Agave jobs
  dockeropts=" --user=0:${CI_GID}"
  echo "Under CI, setting user group"
  docker run ${dockeropts} -e "BRANCH=${ghprbSourceBranch}" $MOUNTS pipeline:${BUILD_ID}
else
  echo "Local run"
  docker run $MOUNTS sd2e/sd2e_integration:1.0
fi