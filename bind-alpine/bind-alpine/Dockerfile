FROM alpine:latest
ARG BUILD_DATE
ARG VCS_REF
ARG HTTP_PROXY
ARG HTTPS_PROXY
LABEL org.opencontainers.image.authors="Rich Braun docker@instantlinux.net, Proteus Ndoskrnl lollipop.studio.cn@gmail.com" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.license="GPL-3.0" \
    org.label-schema.name="bind-alpine" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/magic0whi/ActiveDomain-Docker"

ENV TZ="UTC"

COPY entrypoint.sh /usr/local/bin/
RUN export http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} && \
    apk add --update --no-cache tzdata bind bind-libs bind-tools && \
    chmod 0755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]