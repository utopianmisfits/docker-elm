FROM alpine:3.10.3

ENV ELM_VERSION=0.19.1
ENV ELM_URL=https://github.com/elm/compiler/releases/download/${ELM_VERSION}/binary-for-linux-64-bit.gz

RUN wget -O - ${ELM_URL} | gunzip -c >/usr/local/bin/elm
RUN chmod +x /usr/local/bin/elm

ENTRYPOINT ["elm"]

