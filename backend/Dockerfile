# Multi-stage build for Pharmacy OS Backend
# Stage 1: Build the Go binary
FROM golang:1.21-alpine AS builder

# Install build dependencies (minimal)
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum first (for caching)
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire source code
COPY . .

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

# Create non-root user for security (optional)
# RUN adduser -D -h /app appuser

# Set working directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/server .

# Make binary executable
RUN chmod +x ./server

# Change ownership to non-root user (optional)
# RUN chown -R appuser:appuser /app

# Switch to non-root user (optional)
# USER appuser

# Expose the port
EXPOSE 8080

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/v1/health || exit 1

# Run the binary
CMD ["./server"]
