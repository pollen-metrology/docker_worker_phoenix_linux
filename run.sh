#!/bin/bash

term_handler() {
      echo "Unregister Runner..."
      gitlab-runner unregister --all-runners
    }

start() {
  echo "Register runner..."

  gitlab-runner register \
    --non-interactive \
    --executor "shell" \
    --docker-image alpine:latest \
    --url "https://gitlab.com/" \
    --registration-token $KUBERNETES_RUNNER_REGISTER_TOKEN \
    --description "Kubernetes-Runner" \
    --tag-list $KUBERNETES_RUNNER_TAG \
    --cache-type "s3" \
    --cache-shared=true \
    --cache-s3-server-address $KUBERNETES_RUNNER_CACHE_SERVER_ADDRESS \
    --cache-s3-access-key $KUBERNETES_RUNNER_CACHE_ACCESS_KEY \
    --cache-s3-secret-key $KUBERNETES_RUNNER_CACHE_SECRET_KEY \
    --cache-s3-bucket-name "runner" \
    --run-untagged="true" \
    --locked="false" &&

  echo "Run the runner... "  

  gitlab-runner run &

# Keep Alive
  while true
    do
      tail -f /dev/null & wait ${!}
    done
  
  }


trap 'kill ${!}; term_handler' SIGTERM

start ${!}
#tail -f /dev/null

#Extra line added in the script to run all command line arguments
#exec "$@";
#while true
#    do
#      tail -f /dev/null & wait ${!}
#    done
