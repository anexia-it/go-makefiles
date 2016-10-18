// Package auto contains example code that is to be used with go-makefile's
// "auto" feature
package auto

//go:generate echo "test"

// Test returns the string "test"
func Test() string {
	return "test"
}
