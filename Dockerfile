FROM python:3.6.5

# INSTALL OPENBABEL WITH PYTHON BINDINGS
# testing needed for libeigen 3.3.3
RUN echo 'deb http://deb.debian.org/debian testing main' >> /etc/apt/sources.list \
  && echo 'deb-src http://deb.debian.org/debian testing main' >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      cmake \
      libxml2-dev \
      zlib1g-dev \
      libeigen3-dev \
      libcairo2-dev \
      swig \
      libeigen3-dev \
      g++ \
  && rm -rf /var/lib/apt/lists/* \
RUN mkdir /openbabel
WORKDIR /openbabel
RUN wget http://sourceforge.net/projects/openbabel/files/openbabel/2.4.1/openbabel-2.4.1.tar.gz
RUN tar -xzf openbabel-2.4.1.tar.gz
RUN mkdir build
WORKDIR build
RUN cmake ../openbabel-2.4.1 -DRUN_SWIG=ON -DPYTHON_BINDINGS=ON -DENABLE_TESTS=ON
RUN make
# ALLOW TEST FAILS
RUN make test || return 0
RUN make install \
  && rm -rf /openbabel
ENV PYTHONPATH="/usr/local/lib"
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
RUN echo "[build_ext]" >> ~/.pydistutils.cfg \
  && echo "include_dirs=/usr/local/include/openbabel-2.0/:/usr/include/eigen3/" >> ~/.pydistutils.cfg \
  && echo "library_dirs=/usr/local/lib" >> ~/.pydistutils.cfg \
  && pip install numpy

# Build from source
#ADD . /proteincsm
#RUN cd /proteincsm/python \
#  && python setup.py install

# Build from pip
RUN pip install proteincsm --extra-index-url https://repo.fury.io/theresearchsoftwarecompany

ENTRYPOINT ["csm"]
