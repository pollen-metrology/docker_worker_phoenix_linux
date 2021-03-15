# docker build -t pollenm/docker_worker_phoenix_linux_test .
# docker run -it pollenm/docker_worker_phoenix_linux_test
# push to docker-hub : docker push pollenm/docker_worker_phoenix_linux_test
# push to github : git add Dockerfile && git commit -m "update" && git push
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

#FROM ubuntu:19.10 AS pollen_cxx_development_environment_0320
FROM ubuntu:20.04 AS pollen_cxx_development_environment_0320

LABEL vendor="Pollen Metrology"
LABEL maintainer="herve.ozdoba@pollen-metrology.com"

ARG DEBIAN_FRONTEND=noninteractive

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
    apt-get install --assume-yes gcc-9-multilib g++-9-multilib libstdc++-9-dev libgl1-mesa-dev \
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
FROM pollen_cxx_development_environment_0320 AS phoenix_development_environment_0320

ENV PHOENIX_TARGET_TRIPLET=x64-linux

ARG VCPKG_COMMIT=411b4cc

RUN git clone --quiet --recurse-submodules --branch master https://github.com/Microsoft/vcpkg.git /opt/vcpkg &&\
    cd /opt/vcpkg && git checkout --quiet ${VCPKG_COMMIT} &&\
    /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries

ENV PATH="/opt/vcpkg/vcpkg:${PATH}"

RUN /opt/vcpkg/vcpkg update
RUN /opt/vcpkg/vcpkg install --triplet ${PHOENIX_TARGET_TRIPLET} --clean-after-build \
         boost-stacktrace boost-iostreams boost-core boost-math boost-random boost-format boost-crc \
         opencv3[core,contrib,tiff,png,jpeg] vxl eigen3 gtest boost-geometry nlopt protobuf
#----------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------------------------------#

FROM phoenix_development_environment_0320 AS pyphoenix_development_environment_0320

ENV PYTHON_PHOENIX_TARGET_TRIPLET=x64-linux

#RUN apt-get update &&\
#    apt-get upgrade --assume-yes &&\
#    apt-get install --assume-yes python3 python3-pip python3-dev &&\
#    python3 -m pip install --quiet --upgrade --no-cache-dir pip &&\
#    rm --force --recursive /var/lib/apt/lists/*

# Install tools from Python install
RUN apt-get update &&\
    apt-get upgrade --assume-yes &&\
    apt install wget zlib1g-dev sqlite libsqlite3-dev -y


# Install Python 3.6.10
RUN cd /tmp &&\
    wget https://www.python.org/ftp/python/3.6.10/Python-3.6.10.tar.xz &&\
    tar xvf Python-3.6.10.tar.xz &&\
    cd Python-3.6.10 &&\
    ./configure --enable-shared  --prefix=/usr &&\
    make install &&\
    python3.6 --version
#RUN python3.6 -m pip install --upgrade pip    

# Install Python 3.7.7
RUN cd /tmp &&\
    wget https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tar.xz &&\
    tar xvf Python-3.7.7.tar.xz &&\
    cd Python-3.7.7 &&\
    ./configure --enable-shared  --prefix=/usr &&\
    make install &&\
    python3.7 --version
#RUN python3.7 -m pip install --upgrade pip     

# Install Python 3.8.2
RUN cd /tmp &&\
    wget https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tar.xz &&\
    tar xvf Python-3.8.2.tar.xz &&\
    cd Python-3.8.2 &&\
    ./configure --enable-shared  --prefix=/usr &&\
    make install &&\
    python3.8 --version
#RUN python3.8 -m pip install --upgrade pip     

# Install Conan
RUN python3 -m pip install conan    

# Do nothing - already installed
#RUN /opt/vcpkg/vcpkg install --triplet ${PYTHON_PHOENIX_TARGET_TRIPLET} --clean-after-build \
#        opencv3[core,contrib,tiff,png,jpeg]
#----------------------------------------------------------------------------------------------------------------------#

# Install intel mkl (must have pip)
RUN apt-get update
RUN apt-get -y install python2 && cd /tmp && curl https://bootstrap.pypa.io/2.7/get-pip.py --output get-pip.py && python2 get-pip.py
#RUN apt-get install -y python3-pip
# mkl
RUN pip install mkl_include==2021.1.1
RUN pip install tbb==2021.1.1
# pytorch
RUN cd /tmp &&\
    wget https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-1.7.1%2Bcpu.zip &&\
    mkdir -p /lib/libtorch/libtorch &&\
    unzip libtorch-shared-with-deps-1.7.1+cpu.zip -d /lib/libtorch/libtorch


RUN cd /tmp &&\
    wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.7.1%2Bcpu.zip &&\
    mkdir -p /lib/libtorch/libtorch_cxx11 &&\
    unzip libtorch-cxx11-abi-shared-with-deps-1.7.1+cpu.zip -d /lib/libtorch/libtorch_cxx11

# GITLAB RUNNER"
FROM pyphoenix_development_environment_0320 AS gitlab-runner_development_environment_0320

#RUN apt-get update &&\
#    apt-get install gitlab-runner -y

RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash &&\
    apt-get update &&\
    apt-get install gitlab-runner -y

COPY run.sh /
RUN chmod 755 /run.sh

ENTRYPOINT ["/./run.sh", "-D", "FOREGROUND"]
###ENTRYPOINT ["tail", "-f", "/dev/null"]
#----------------------------------------------------------------------------------------------------------------------#
