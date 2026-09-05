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
RUN apk --no-cache add ca-certificates wget tzdata

# Set working directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/backend/server .

# Make binary executable
RUN chmod +x ./server

# Expose the port (DockHosting will use its own port mapping)
EXPOSE 8080

# Health check endpoint
# Using wget (installed above)
# DockHosting passes PORT env var (usually 80), fallback to 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/v1/health || exit 1

# Run the binary directly (simple & reliable!)
CMD ["./server"]
