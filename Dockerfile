# xray-core v26.11.9 (pinned) — builder stage provides the binary,
# runtime stage is Alpine (has a shell; the official xray image has none).
FROM ghcr.io/xtls/xray-core:v26.11.9 AS builder

FROM alpine:3.21
RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/local/bin/xray /usr/local/bin/xray
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# The platform assigns $PORT at runtime; nothing is hard-coded here.
ENTRYPOINT ["/entrypoint.sh"]
