#!/bin/bash
#
# Run locust load test
#
#####################################################################
ARGS="$@"
HOST="${1}"
SCRIPT_NAME=`basename "${0}"`
INITIAL_DELAY=1
TARGET_HOST="${HOST}"
USERS=2
SPAWN_RATE=10
TIMEOUT=10s


do_check() {

  # check hostname is not empty
  if [ "${TARGET_HOST}x" == "x" ]; then
    echo "TARGET_HOST is not set; use '-h hostname:port'"
    exit 1
  fi

  # check for locust
  if [ ! `command -v locust` ]; then
    echo "Python 'locust' package is not found!"
    exit 1
  fi

  # check locust file is present
  if [ -n "${LOCUST_FILE:+1}" ]; then
  	echo "Locust file: ${LOCUST_FILE}"
  else
  	LOCUST_FILE="locustfile.py" 
  	echo "Default Locust file: ${LOCUST_FILE}" 
  fi
}

do_exec() {
  sleep $INITIAL_DELAY

  # check if host is running
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${TARGET_HOST}") 
  if [ ${STATUS} -ne 200 ]; then
      echo "${TARGET_HOST} is not accessible"
      exit 1
  fi

  echo "Will run ${LOCUST_FILE} against ${TARGET_HOST}. Spawning ${USERS} users with ${SPAWN_RATE} spawn-rate for ${TIMEOUT} time."
  locust --host="http://${TARGET_HOST}" -f "${LOCUST_FILE}" --users=${USERS} --spawn-rate=${SPAWN_RATE} -t=${TIMEOUT} --headless --only-summary
  echo "done"
}

do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} [ hostname ] OPTIONS

Options:
  -d  Delay before starting
  -h  Target host url, e.g. http://localhost/
  -u  Number of users (default 2)
  -r  Rate per second in which users are spawned (default 5)
  -t  Run time (default 10s)

Description:
  Runs a Locust load simulation against specified host.

EOF
  exit 1
}



while getopts ":d:h:u:r:t:" o; do
  case "${o}" in
    d)
        INITIAL_DELAY=${OPTARG}
        #echo $INITIAL_DELAY
        ;;
    h)
        TARGET_HOST=${OPTARG}
        #echo $TARGET_HOST
        ;;
    u)
        USERS=${OPTARG:-2}
        #echo $USERS
        ;;
    r)
        SPAWN_RATE=${OPTARG:-5}
        #echo $SPAWN_RATE
        ;;
    t)
        TIMEOUT=${OPTARG:-10s}
        #echo $TIMEOUT
        ;;
    *)
        do_usage
        ;;
  esac
done

do_check
do_exec
