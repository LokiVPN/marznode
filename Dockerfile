FROM tobyxdd/hysteria:v2 AS hysteria-image
FROM jklolixxs/sing-box:latest AS sing-box-image

FROM python:3.12-alpine

ENV PYTHONUNBUFFERED=1

COPY --from=hysteria-image /usr/local/bin/hysteria /usr/local/bin/hysteria
COPY --from=sing-box-image /usr/local/bin/sing-box /usr/local/bin/sing-box

WORKDIR /app

COPY . .

RUN mkdir /etc/init.d/

RUN apk add --no-cache curl unzip

RUN ARCH=$(case "$(uname -m)" in x86_64) echo "64";; aarch64) echo "arm64-v8a";; esac) && \
    curl -L -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${ARCH}.zip" && \
    unzip /tmp/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip
    
RUN apk add --no-cache alpine-sdk libffi-dev && pip install --no-cache-dir -r /app/requirements.txt && apk del -r alpine-sdk libffi-dev curl unzip

CMD ["python3", "marznode.py"]
