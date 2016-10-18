package auto_test

import "testing"
import "github.com/anexia-it/go-makefiles/examples/auto"

func TestTest(t *testing.T) {
	if auto.Test() != "test" {
		t.FailNow()
	}
}
