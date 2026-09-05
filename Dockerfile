# Multi-stage build for Pharmacy OS Backend
# This Dockerfile is at repository root, builds from backend/
# Optimized for DockHosting/Coolify deployment

# Stage 1: Build the Go binary
FROM golang:1.21-alpine AS builder

# Install build dependencies (minimal)
RUN apk add --no-cache git ca-certificates

# Set working directory to backend
WORKDIR /app/backend

# Copy go.mod and go.sum first (for caching)
COPY backend/go.mod backend/go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire backend source code
COPY backend/ .

# Build the binary
# -ldflags="-s -w" strips debug info for smaller binary
# -o server names the output correctly!
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server ./cmd/server

# Stage 2: Production image (minimal)
FROM alpine:latest

# Install runtime dependencies
# - ca-certificates for HTTPS/SSL connections
# - wget for health checks
# - tzdata for timezone support
# - bash for startup script
RUN apk --no-cache add ca-certificates wget tzdata bash

# Set working directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/backend/server .

# Create startup script that handles dynamic port assignment
RUN echo '#!/bin/bash\n\
# Get PORT from environment (DockHosting provides this)\n\
PORT="${PORT:-8080}"\n\
\n\
echo "Starting Pharmacy OS Backend on port ${PORT}"\n\
echo "Health check available at: http://localhost:${PORT}/api/v1/health"\n\
\n\
# Start the server\n\
exec ./server' > /app/start.sh && chmod +x /app/start.sh

# Make binary executable
RUN chmod +x ./server

# Expose the port (DockHosting will use its own port mapping)
EXPOSE 8080

# Health check endpoint
# Using wget (installed above)
# Try the configured port first, then fallback ports
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD sh -c 'PORT="${PORT:-8080}"; wget --no-verbose --tries=1 --spider "http://localhost:${PORT}/api/v1/health" || exit 1'

# Run using startup script
CMD ["/app/start.sh"]
