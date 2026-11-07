FROM alpine:latest

# 安装基础依赖
RUN apk add --no-cache --virtual .build-deps ca-certificates curl jq

# 下载官方最新 Xray 内核
RUN mkdir -p /tmp/xray && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray

# 注入自适应多协议配置（监听环境变量 PORT）
CMD echo '{\
    "log": {"loglevel": "warning"},\
    "inbounds": [{\
        "port": '"$PORT"',\
        "protocol": "vless",\
        "settings": {\
            "clients": [{"id": "d4b07384-d223-49a6-a5e4-ee7415443837"}],\
            "decryption": "none"\
        },\
        "streamSettings": {\
            "network": "xhttp",\
            "xhttpSettings": {"path": "/vpn-stream","mode": "stream-one"}\
        }\
    }],\
    "outbounds": [{"protocol": "freedom"}]\
}' > /usr/local/bin/config.json && /usr/local/bin/xray run -config /usr/local/bin/config.json