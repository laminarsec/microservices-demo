#!/bin/bash

# Run example:
# ./run_loadtest_locally.sh -h localhost:<front-end-ip>:30001 -u <users_count> -t <run_time>
pushd ../docker-image
./build.sh
popd

docker run --rm --net=host load-test $@
