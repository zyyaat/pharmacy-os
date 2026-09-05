# Multi-stage build for Pharmacy OS Backend
# This Dockerfile is at repository root, builds from backend/

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

# Install runtime dependencies (only ca-certificates for HTTPS)
RUN apk --no-cache add ca-certificates tzdata

# Create non-root user for security
RUN adduser -D -h /app appuser

# Set working directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/backend/server .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the port
# DockHosting will pass PORT env var, fallback to 8080
EXPOSE 8080

# Health check endpoint (optional but recommended)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/v1/health || exit 1

# Run the binary
CMD ["./server"]
