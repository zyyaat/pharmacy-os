// Package middleware - Permissions middleware
//
// MANDATORY FILE: This file is reserved for future Permission system implementation.
// Do not delete - will be used in Task N (Permissions System).
//
// This middleware will implement RequirePermission(key string) function
// that checks if the authenticated user has the required permission.

package middleware

import (
	"net/http"
	
	"github.com/gin-gonic/gin"
)

// RequirePermission returns a middleware that checks for a specific permission
// TODO: Implement permission checking against employee_permissions table
func RequirePermission(key string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, _ := c.Get("user_id")
		
		// TODO: Query employee_permissions table
		// SELECT 1 FROM employee_permissions 
		// WHERE employee_id = $1 AND permission_key = $2
		_ = userID
		_ = key
		
		// Placeholder - will be implemented in permissions task
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
			"error": "Insufficient permissions",
			"required": key,
		})
		
		// c.Next() // Uncomment after implementation
	}
}

// HasPermission checks if a user has a specific permission
// TODO: Implement permission check logic
func HasPermission(c *gin.Context, key string) bool {
	// Placeholder implementation
	_ = c
	_ = key
	return false
}
