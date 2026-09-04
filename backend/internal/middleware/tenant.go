package middleware

import (
	"github.com/gin-gonic/gin"
)

// TenantContext sets the pharmacy_id for RLS (Row Level Security)
// Uses SET LOCAL app.current_pharmacy_id to isolate tenant data
func TenantContext() gin.HandlerFunc {
	return func(c *gin.Context) {
		pharmacyID, exists := c.Get("pharmacy_id")
		if !exists {
			// For public endpoints, skip tenant context
			c.Next()
			return
		}
		
		// TODO: Get DB connection from context and execute:
		// SET LOCAL app.current_pharmacy_id = $1
		_ = pharmacyID
		
		c.Next()
	}
}
