FROM alpine:3.7

RUN apk update && apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    openssl \
    && update-ca-certificates

COPY rootfs /
ENV GIT_SSH=/gitssh.sh
ENV GIT_ASKPASS=/askpass.sh
CMD /clone.sh
