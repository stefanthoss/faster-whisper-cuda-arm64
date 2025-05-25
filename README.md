# faster-whisper-cuda-arm64

This is a [Faster Whisper](https://github.com/SYSTRAN/faster-whisper) Docker image for arm64 with Nvidia GPU support.

If you're looking for an x86_64 image or don't need GPU support, I recommend checking out the excellent [linuxserver/faster-whisper](https://github.com/linuxserver/docker-faster-whisper).

## Configuration

| Environment Variable | Description |
| --- | --- |
| `WHISPER_MODEL` | Whisper model that will be used for transcription. From [here](https://github.com/SYSTRAN/faster-whisper/blob/master/faster_whisper/utils.py#L12-L31), all with `-int8` compressed variants |
| `WHISPER_BEAM` | Number of candidates to consider simultaneously during transcription. |
| `WHISPER_LANG` | Language that you will speak to the add-on. |

## Development

```shell
docker build -t faster-whisper-cuda-arm64:dev .

COMPOSE_BAKE=true docker compose -f docker-compose.dev.yml up --build
```
