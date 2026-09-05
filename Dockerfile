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

# Expose common ports (DockHosting may use 80, 8080, or dynamic port)
EXPOSE 80 8080

# NOTE: Health check disabled here to avoid port mismatch issues
# DockHosting/Coolify will handle health checks based on its configuration
# If you need custom healthcheck, configure it in DockHosting UI settings

# Run the binary directly
CMD ["./server"]
