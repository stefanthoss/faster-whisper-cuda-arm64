# faster-whisper-cuda-arm64

This is a [Faster Whisper](https://github.com/SYSTRAN/faster-whisper) Docker image for arm64 with Nvidia GPU support.

If you're looking for an x86_64 image or don't need GPU support, I recommend checking out the excellent [linuxserver/faster-whisper](https://github.com/linuxserver/docker-faster-whisper).

## Requirements

The image is built on CUDA 13, which supports compute capability 7.5 and up: Turing, Ampere, Ada, Hopper and Blackwell, including Jetson Orin and Jetson Thor. Kernels are compiled for:

| Compute capability | GPUs |
| --- | --- |
| 7.5 | Turing |
| 8.0, 8.6 | Ampere |
| 8.7 | Jetson Orin |
| 8.9 | Ada |
| 9.0 | Hopper |
| 10.0 | Blackwell Datacenter |
| 11.0 | Jetson Thor |
| 12.0, 12.1 | Blackwell GeForce, DGX Spark |

**The Nvidia generations Maxwell, Pascal, Volta and Jetson Xavier are not supported since CUDA 13.**

Most of the build time is CTranslate2 compiling CUDA kernels for every architecture in the table. When building for one machine, narrow it down with the `CUDA_ARCH_LIST` and `CUDA_NVCC_FLAGS` build arguments to cut compile time.

## Configuration

| Environment Variable | Description |
| --- | --- |
| `WHISPER_MODEL` | Whisper model that will be used for transcription. From [here](https://github.com/SYSTRAN/faster-whisper/blob/master/faster_whisper/utils.py#L12-L31), all with `-int8` compressed variants |
| `WHISPER_BEAM` | Number of candidates to consider simultaneously during transcription. |
| `WHISPER_LANG` | Language that you will speak to the add-on. |

## Deployment

Download `docker-compose.yml`, change the environment variables as needed, and start it with `docker compose up -d`.

## Development

```shell
docker build -t faster-whisper-cuda-arm64:dev .

COMPOSE_BAKE=true docker compose -f docker-compose.dev.yml up --build
```
