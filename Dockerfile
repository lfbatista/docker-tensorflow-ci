FROM debian:stretch-slim

RUN mkdir /code
COPY . /code

ENV PYTHONUNBUFFERED 1

ENV BUILD_PACKAGES="\
        build-essential \
        linux-headers-4.9 \
        cmake \
        tcl-dev \
        libssl-dev \
        #wget \
        curl" \
    APT_PACKAGES="\
        ca-certificates" \
    PIP_PACKAGES="\
        h5py \
        requests \
        pillow \
        futures \
        flask \
        tensorflow==2.0.0 \
        keras_applications==1.0.8 \
        protobuf \
        pybind11" \
    PYTHON_VER=3.6.10 

RUN set -ex; \
    apt-get -qq update -y; \
    apt-get -qq upgrade -y; \
    apt-get -qq install -y --no-install-recommends ${APT_PACKAGES} > /dev/null; \
    apt-get -qq install -y --no-install-recommends ${BUILD_PACKAGES} > /dev/null; \
    cd /tmp && curl -s  https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz -LO > /dev/null; \
    tar xf Python-${PYTHON_VER}.tgz; \
    cd Python-${PYTHON_VER}; \
    ./configure --enable-optimizations && make -j8 && make altinstall; \
    #./configure && make -s -j8 && make -s altinstall; \
    ln -s /usr/local/bin/python3.6 /usr/local/bin/python; \
    ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip; \
    ln -s /usr/local/bin/idle3.6 /usr/local/bin/idle; \
    ln -s /usr/local/bin/pydoc3.6 /usr/local/bin/pydoc; \
    ln -s /usr/local/bin/python3.6m-config /usr/local/bin/python-config; \
    ln -s /usr/local/bin/pyvenv-3.6 /usr/local/bin/pyvenv; \
    pip install -qq -U -V pip > /dev/null; \
    pip install -qq -U -v setuptools wheel > /dev/null; \
    #pip install -U -v ${PIP_PACKAGES}; \
    pip install -qq -r /code/requirements.txt > /dev/null; \
    apt-get -q remove --purge --auto-remove -y ${BUILD_PACKAGES} > /dev/null; \
    apt-get clean; \
    apt-get autoclean; \
    apt-get autoremove; \
    rm -rf /tmp/* /var/tmp/*; \
    rm -rf /var/lib/apt/lists/*; \
    rm -f /var/cache/apt/archives/*.deb \
        /var/cache/apt/archives/partial/*.deb \
        /var/cache/apt/*.bin > /dev/null; \
    find / -name __pycache__ | xargs rm -r; \
    rm -rf /root/.[acpw]*

# Metadata
ARG BUILD_DATE
ARG VCS_REF
LABEL build-date=$BUILD_DATE \
  name="Docker Deployment with GitHub Actions" \
  description="Docker Deployment on Heroku with GitHub Actions" \
  vcs-ref=$VCS_REF \
  vcs-url="https://github.com/lfbatista/docker-tensorflow-ci" \
  version="1.0" \
  dockerfile="/Dockerfile"

WORKDIR /code/app

#CMD ["python", "app.py"]
CMD gunicorn wsgi:app --bind 0.0.0.0:$PORT
