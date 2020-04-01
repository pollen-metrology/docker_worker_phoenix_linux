# docker build -t pollenm/docker_worker_phoenix_linux .
##FROM ubuntu:19.10
##LABEL MAINTENER Pollen Metrology <admin-team@pollen-metrology.com>

## Indispensable sinon l'installation demande de choisir le keyboard
##ENV DEBIAN_FRONTEND=noninteractive

##RUN apt-get update

##RUN apt-get install vim -y

# CONTENT FOR BUILD
#----------------------------------------------------------------------------------------------------------------------#
#                                              Pollen Metrology CONFIDENTIAL                                           #
#----------------------------------------------------------------------------------------------------------------------#
# [2014-2020] Pollen Metrology
# All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains the property of Pollen Metrology.
# The intellectual and technical concepts contained herein are  proprietary to Pollen Metrology and  may be covered by
# French, European and/or Foreign Patents, patents in process, and are protected by trade secret or copyright law.
# Dissemination of this information or reproduction of this material is strictly forbidden unless prior written
# permission is obtained from Pollen Metrology.
#----------------------------------------------------------------------------------------------------------------------#
# Build:
#    - docker build -t pollenm/docker_worker_phoenix_linux . && docker-compose up -d && docker exec -it docker_worker_phoenix_linux /bin/bash
# Compilation:
#    - [Phoenix / PyPhoenix] LLVM/Clang (>= 9.0.0)
#    - [Phoenix / PyPhoenix] GNU Compiler (>= 9.0.0)
# Dependancies:
#    - [Phoenix / PyPhoenix] install VCPKG - instructions available on github
#    - [PyPhoenix] Install python (>= 3.7.0) + development packages
# C++ Source code formatting :
#    - [Phoenix / PyPhoenix] clang-format (>= 9.0.0 - available with LLVM)
# C++ Source code static analysis :
#    - [Phoenix] clang-tidy (>= 9.0.0 - available with LLVM)
#    - [Phoenix] cppcheck (>= 1.89.0)
#    - [PyPhoenix] Pylint (install using "python -m pip")
#    - [PyPhoenix] Mypy (install using "python -m pip")
# C++ documentation generation :
#    - [Phoenix] doxygen (>= 1.8.0)
#    - [Phoenix] dot (>= 2.40.0 available with graphviz)
#    - [PyPhoenix] Sphinx (install using "python -m pip")
# C++ Source code coverage:
#    - [Phoenix] gcov (>= 9.0.0 - available with GNU C Compiler)
#    - [Phoenix] lcov (>= 1.14.0)
# Memory errors detector:
#    - [Phoenix] valgrind (>= 3.15.0)
# Benchmark :
#    -  [PyPhoenix] pytest-benchmark (install using "python -m pip")
# Package generation :
#    - [Phoenix] using conan package manager (install using "python -m pip")
#    - [Phoenix] using CPack : done by CMake
#    - [PyPhoenix] using Setuptools : done by Python
# Deployment :
#    - [Phoenix] using conan package manager (install using "python -m pip")
#    - [PyPhoenix] To be discussed (Q/A - using Jupyter notebooks for PyPhoenix)
#----------------------------------------------------------------------------------------------------------------------#

FROM ubuntu:19.10 AS pollen_cxx_development_environment_0320

LABEL vendor="Pollen Metrology"
LABEL maintainer="herve.ozdoba@pollen-metrology.com"

# Commit 411b4cc is the last working version for compiling VXL (then contributors brokes the port file)
ARG CMAKE_VERSION=v3.16.4

ENV CC=gcc-9
ENV CXX=g++-9

# Official Ubuntu images automatically run apt-get clean, so explicit invocation is not required.
# CMake is rebuilt because Phoenix and PyPhoenix require a version greater than 3.16 which is unavailable in Packages provided by ubuntu 19.10
# -> lcov is rebuilt because of an incompatility with gcov 9 (dependencies : libperlio-gzip-perl and libjson-perl)
# -> curl unzip tar are required by VCPKG
# -> nano, used as a tiny editor, is installed for convenience
# -> powershell: common scripting for both Windows and Linux images
RUN apt-get update &&\
    apt-get upgrade --assume-yes &&\
    apt-get install --assume-yes gcc-9-multilib g++-9-multilib libstdc++-9-dev \
                                 clang-9 clang-format-9 clang-tidy-9 clang-tools-9 libc++-9-dev libc++abi-9-dev \
                                 valgrind cppcheck doxygen graphviz libssl-dev \
                                 curl unzip tar git make ninja-build nano \
                                 libperlio-gzip-perl libjson-perl &&\
    curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/powershell-7.0.0-linux-x64.tar.gz &&\
    mkdir -p /opt/microsoft/powershell/7 && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 &&\
    chmod +x /opt/microsoft/powershell/7/pwsh && ln -s /opt/microsoft/powershell/7/pwsh /usr/local/bin/pwsh &&\
    git clone --quiet --recurse-submodules --branch master --single-branch https://github.com/linux-test-project/lcov.git /tmp/lcov &&\
    cd /tmp/lcov && make install PREFIX=/usr/local &&\
    git clone --quiet --recurse-submodules --single-branch --branch ${CMAKE_VERSION} https://gitlab.kitware.com/cmake/cmake.git /tmp/cmake &&\
    cd /tmp/cmake && /tmp/cmake/bootstrap --no-qt-gui --parallel=$(nproc) --prefix=/usr/local &&\
    make -j $(nproc) && make -j $(nproc) install &&\
    rm --force --recursive /var/lib/apt/lists/* /tmp/cmake /tmp/lcov /tmp/powershell.tar.gz

#----------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------------------------------#
# GITLAB RUNNER"
FROM pollen_cxx_development_environment_0320 AS gitlab-runner_development_environment_0320

RUN apt-get update &&\
    apt-get install gitlab-runner -y

COPY run.sh /
RUN chmod 755 /run.sh

ENTRYPOINT ["/./run.sh", "-D", "FOREGROUND"]
#----------------------------------------------------------------------------------------------------------------------#