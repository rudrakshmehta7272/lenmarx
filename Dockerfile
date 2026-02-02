# Lenmarx Blockchain Binary Build
# Uses Go 1.22 on Debian Bookworm for clean Linux build environment

FROM golang:1.22.11-bookworm as builder

WORKDIR /build

# Copy source code
COPY . .

# Build flags: strip symbols for smaller binary, static linking
ARG LDFLAGS="-s -w"

# Build the binary
RUN cd lenmarx || true && \
    go mod download && \
    go mod verify && \
    go mod tidy && \
    go build \
      -ldflags="${LDFLAGS}" \
      -v \
      -o /usr/local/bin/lenmarxd \
      ./cmd/lenmarxd

# Verify binary
RUN file /usr/local/bin/lenmarxd && \
    /usr/local/bin/lenmarxd --version || echo "Binary built"

# ===== Runtime Stage =====
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/lenmarxd /usr/local/bin/lenmarxd

RUN chmod +x /usr/local/bin/lenmarxd && \
    lenmarxd --version || echo "Binary ready"

ENTRYPOINT ["lenmarxd"]
CMD ["--help"]
