#!/bin/bash

#set -m

 #git config user.name "$GIT_USER_NAME"
 #git config user.email "$GIT_USER_EMAIL"

#tail -f /dev/null

 #exec "$@"

#registration_token=pCapPtgyG2vyoW1Xwbh7

echo "Register runner..."

#gitlab-runner register \
#    --non-interactive \
#    --registration-token ${registration_token} \
#    --locked=false \
#    --description runner-phoenix-linux \
#    --url https://gitlab.com/ \
#    --executor docker \
#    --docker-image docker:stable &&

#    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
#    #--docker-network-mode gitlab-network 
#    --access-level="not_protected" \
#    --tag-list kubernetes,test
#    >> /var/log/console.log 2>&1

#docker run --rm -v /srv/gitlab-runner/config:/etc/gitlab-runner 

#gitlab-runner register \
#  --non-interactive \
#  --executor "docker" \
#  --docker-image docker:latest \
#  --url "https://gitlab.com/" \
#  --registration-token ${registration_token} \
#  --description "docker-runner" \
#  --tag-list "docker,aws" \
#  --run-untagged="true" \
#  --locked="false" &&
#  #--access-level ="not_protected"


#################
#gitlab-runner verify --delete
#
#gitlab-runner register \
#  --non-interactive \
#  --registration-token pCapPtgyG2vyoW1Xwbh7 \
#  --locked=false \
#  --description runner-phoenix-linux \
#  --url https://gitlab.com/ \
#  --executor shell \
#  --tag-list phoenix &&
####################

#gitlab-runner start &&



#gitlab-runner verify

#if [ $? -gt 0 ]; then
#  echo "===> ERROR: Registration failed !"
#  #exit 1
#  else
#  echo "===> Register OK"
#fi    

#gitlab-runner verify


#gitlab-runner register --non-interactive \
#      --url "https://gitlab.com/" \
#      --executor kubernetes \
#      --config "/etc/gitlab-runner/config.toml" \
#      --registration-token nYAsaK9DqxZevC5Sn5Qn \
#      --locked=false \
#      --description "Kubernetes-Runner" \
#      --tag-list phoenix \
#      --kubernetes-privileged

gitlab-runner register \
  --non-interactive \
  --executor "shell" \
  --docker-image alpine:latest \
  --url "https://gitlab.com/" \
  --registration-token "nYAsaK9DqxZevC5Sn5Qn" \
  --description "Kubernetes-Runner" \
  --tag-list "phoenix,pyphoenix" \
  --run-untagged="true" \
  --locked="false" \
  &&
  #--access-level="not_protected"



gitlab-runner run &&
#tail -f /dev/null

#Extra line added in the script to run all command line arguments
exec "$@";
#exec "tail -f /dev/null" &