FROM nvidia/cuda:12.6.0-cudnn-devel-ubuntu24.04

ARG WHISPER_VERSION=2.4.0
ARG CTRANSLATE2_VERSION=4.6.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        python3 \
        python3-pip \
        wget \
        git \
        python3-dev \
        build-essential \
        cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 --branch "v${CTRANSLATE2_VERSION}" --recursive https://github.com/OpenNMT/CTranslate2.git

RUN cd CTranslate2 && mkdir build && cd build && \
    cmake .. -DWITH_CUDA=ON -DWITH_CUDNN=ON -DWITH_MKL=OFF -DCMAKE_BUILD_TYPE=Release -DOPENMP_RUNTIME=NONE && \
    VERBOSE=1 make -j8 && \
    make install && \
    ldconfig

RUN cd CTranslate2/python \
    && python3 -m pip install --no-cache-dir --break-system-packages -r install_requirements.txt \
    && python3 setup.py bdist_wheel \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        dist/*.whl \
        "wyoming-faster-whisper @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WHISPER_VERSION}.tar.gz"

# TODO: Clean up to reduce image size

COPY run.sh /

EXPOSE 10300

ENTRYPOINT ["bash", "/run.sh"]
