# Versions to bump for a release.
ARG CUDA_VERSION=13.5.0
ARG UBUNTU_VERSION=24.04
ARG CTRANSLATE2_VERSION=4.9.1
ARG WYOMING_FASTER_WHISPER_VERSION=3.9.1
# faster-whisper 1.2.1 calls av.open(metadata_errors=...), which av 19 removed.
ARG AV_VERSION_SPEC="av>=11,<19"

FROM nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu${UBUNTU_VERSION} AS builder

ARG CTRANSLATE2_VERSION
# CTranslate2 4.9 replaced FindCUDA with native CMake CUDA support, so all
# architectures now go through CMAKE_CUDA_ARCHITECTURES as one ; separated list.
# nvcc 13 cannot target pre-Turing GPUs; GPU coverage is in the README.
ARG CUDA_ARCH_LIST="75;80;86;87;89;90;100;110;120;121"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        python3-dev \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 --branch "v${CTRANSLATE2_VERSION}" --recursive https://github.com/OpenNMT/CTranslate2.git \
    && mkdir CTranslate2/build \
    && cd CTranslate2/build \
    && cmake .. -DWITH_CUDA=ON -DWITH_CUDNN=ON -DWITH_MKL=OFF -DCMAKE_BUILD_TYPE=Release -DOPENMP_RUNTIME=NONE \
           -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH_LIST}" \
    && make -j8 \
    && make install \
    && cd ../python \
    && python3 -m pip install --no-cache-dir --no-compile --break-system-packages -r install_requirements.txt \
    && python3 setup.py bdist_wheel \
    && python3 -m pip install --no-cache-dir --no-compile --break-system-packages --no-deps dist/*.whl \
    && mkdir /stage \
    && cp -a "$(python3 -c 'import sysconfig; print(sysconfig.get_paths()["platlib"])')"/ctranslate2* /stage/ \
    && rm -rf /app/CTranslate2

FROM nvidia/cuda:${CUDA_VERSION}-cudnn-runtime-ubuntu${UBUNTU_VERSION}

ARG CTRANSLATE2_VERSION
ARG WYOMING_FASTER_WHISPER_VERSION
ARG AV_VERSION_SPEC

# By SONAME: COPY would dereference libctranslate* into a duplicate per symlink.
COPY --from=builder /usr/local/lib/libctranslate2.so.${CTRANSLATE2_VERSION} /usr/local/lib/libctranslate2.so.4
COPY --from=builder /stage/ /usr/lib/python3/dist-packages/

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --no-compile --break-system-packages \
        "${AV_VERSION_SPEC}" \
        "wyoming-faster-whisper @ https://github.com/OHF-Voice/wyoming-faster-whisper/archive/refs/tags/v${WYOMING_FASTER_WHISPER_VERSION}.tar.gz" \
    && python3 -m pip check

COPY run.sh /

EXPOSE 10300

ENTRYPOINT ["bash", "/run.sh"]
