// Package config handles application configuration
package config

import "os"

// Config holds all application configuration
type Config struct {
	Port         string
	DatabaseURL  string
	JWTSecret    string
	RiverDSN     string
}

// Load reads configuration from environment variables
func Load() *Config {
	return &Config{
		Port:         getEnv("BACKEND_PORT", "8080"),
		DatabaseURL:  getEnv("DATABASE_URL", "postgresql://postgres:postgres@localhost:6543/postgres"),
		JWTSecret:    getEnv("JWT_SECRET", "change-me-in-production"),
		RiverDSN:     getEnv("RIVER_DSN", "postgresql://postgres:postgres@localhost:6543/postgres"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
