#!/bin/bash

USERS=100
SPAWN_RATE=5
TIMEOUT=20s

JOB_TEMPLATE_YAML="loadtest-job.template.yaml"

exit_with_error() {
  echo "${1}"
  echo "Exiting"
  exit 1
}

do_build() {
    pushd ../../docker-image
    ./build.sh
    popd
}

do_run_job() {
    [ -z "${USERS}" ] && exit_with_error "USERS not set"
    [ -z "${SPAWN_RATE}" ] && exit_with_error "SPAWN_RATE not set"
    [ -z "${TIMEOUT}" ] && exit_with_error "TIMEOUT not set"

    export USERS
    export SPAWN_RATE
    export TIMEOUT

    [[ -e "${JOB_TEMPLATE_YAML}" ]] || exit_with_error "can't find ${JOB_TEMPLATE_YAML}"
    job_yaml=`envsubst '${USERS} ${SPAWN_RATE} ${TIMEOUT}' < "${JOB_TEMPLATE_YAML}"`

    echo "${job_yaml}" | kubectl delete -f -
    echo "${job_yaml}" | kubectl apply -f -
}

do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} OPTIONS

Options:
  -u  Number of users (default 100)
  -r  Rate per second in which users are spawned (default 5)
  -t  Run time (default 20s)

Description:
  Runs a Locust load simulation against specified host.

EOF
  exit 1
}

while getopts ":u:r:t:" o; do
  case "${o}" in
    u)
        USERS=${OPTARG:-100}
        ;;
    r)
        SPAWN_RATE=${OPTARG:-5}
        ;;
    t)
        TIMEOUT=${OPTARG:-20s}
        ;;
    *)
        do_usage
        ;;
  esac
done

do_build
do_run_job
