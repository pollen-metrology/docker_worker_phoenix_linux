# docker build -t pollenm/docker_worker_phoenix_linux .
FROM ubuntu:19.10
LABEL MAINTENER Pollen Metrology <admin-team@pollen-metrology.com>

# Indispensable sinon l'installation demande de choisir le keyboard
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install vim -y

# CONTENT FOR BUILD

# GITLAB RUNNER"
RUN apt-get install gitlab-runner -y

COPY run.sh /
RUN chmod 755 /run.sh

ENTRYPOINT ["/./run.sh", "-D", "FOREGROUND"]