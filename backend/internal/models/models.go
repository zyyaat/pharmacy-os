// Package models defines data structures for Pharmacy OS
package models

// Pharmacy represents a pharmacy tenant
type Pharmacy struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Phone     *string   `json:"phone,omitempty"`
	PlanType  string    `json:"plan_type"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
}

// Branch represents a pharmacy branch
type Branch struct {
	ID        string    `json:"id"`
	PharmacyID string  `json:"pharmacy_id"`
	Name      string    `json:"name"`
	Address   string    `json:"address"`
	Phone     *string   `json:"phone,omitempty"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
}

// Employee represents a pharmacy employee
type Employee struct {
	ID        string    `json:"id"`
	PharmacyID string  `json:"pharmacy_id"`
	BranchID  string    `json:"branch_id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Email     string    `json:"email"`
	Phone     *string   `json:"phone,omitempty"`
	Role      string    `json:"role"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Medication represents a medication/inventory item
type Medication struct {
	ID            string    `json:"id"`
	PharmacyID    string    `json:"pharmacy_id"`
	Name          string    `json:"name"`
	GenericName   *string   `json:"generic_name,omitempty"`
	SKU           string    `json:"sku"`
	Quantity      int       `json:"quantity"`
	MinStockLevel int       `json:"min_stock_level"`
	Price         float64   `json:"price"`
	ExpiryDate    *time.Time `json:"expiry_date,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

// AttendanceRecord represents an employee attendance entry
type AttendanceRecord struct {
	ID        string     `json:"id"`
	EmployeeID string   `json:"employee_id"`
	ClockIn   time.Time  `json:"clock_in"`
	ClockOut  *time.Time `json:"clock_out,omitempty"`
	Notes     *string    `json:"notes,omitempty"`
}

// AuditLog represents an audit log entry
type AuditLog struct {
	ID          string    `json:"id"`
	PharmacyID  string    `json:"pharmacy_id"`
	UserID      string    `json:"user_id"`
	Action      string    `json:"action"`
	Resource    string    `json:"resource"`
	ResourceID  string    `json:"resource_id"`
	Details     string    `json:"details"`
	IPAddress   string    `json:"ip_address"`
	CreatedAt   time.Time `json:"created_at"`
}
