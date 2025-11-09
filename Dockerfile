FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS builder

ARG CTRANSLATE2_VERSION=4.6.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        python3 \
        python3-dev \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 --branch "v${CTRANSLATE2_VERSION}" --recursive https://github.com/OpenNMT/CTranslate2.git

RUN cd CTranslate2 \
    && mkdir build \
    && cd build \
    && cmake .. -DWITH_CUDA=ON -DWITH_CUDNN=ON -DWITH_MKL=OFF -DCMAKE_BUILD_TYPE=Release -DOPENMP_RUNTIME=NONE \
    && make -j8 \
    && make install \
    && ldconfig

RUN cd CTranslate2/python \
    && python3 -m pip install --no-cache-dir --break-system-packages -r install_requirements.txt \
    && python3 setup.py bdist_wheel

FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ARG WHISPER_VERSION=3.0.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/libctranslate* /usr/local/lib/

COPY --from=builder /app/CTranslate2/python/dist/*.whl /wheels/

RUN python3 -m pip install --no-cache-dir --break-system-packages \
    /wheels/*.whl \
    "wyoming-faster-whisper @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WHISPER_VERSION}.tar.gz"

COPY run.sh /

EXPOSE 10300

ENTRYPOINT ["bash", "/run.sh"]
