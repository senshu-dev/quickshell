package clipboard

import "testing"

func TestLooksLikeSecret(t *testing.T) {
	secrets := map[string]string{
		"pem private key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEow...",
		"openssh key":     "-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXk=",
		"github classic":  "ghp_" + "aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789",
		"github fine":     "github_pat_" + "11ABCDEFG0123456789_abcdefghijklmnopqrstuv",
		"gitlab":          "glpat-" + "xYz12345AbCdEfGhIjKl",
		"aws access key":  "AKIA" + "IOSFODNN7EXAMPLE",
		"aws sts key":     "ASIA" + "IOSFODNN7EXAMPLE",
		"slack":           "xoxb-" + "123456789012-abcdefABCDEF",
		"anthropic":       "sk-ant-" + "api03-abcdefghijklmnopqrstuvwxyz",
		"jwt":             "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U",
		"kube key data":   "    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQo=",
		"kube token":      "    token: " + "abcdefghijklmnopqrstuvwxyz0123456789",
		"yc iam":          "t1." + "9euelZqJkZuTnpCOi5KPkM2Tj5fGnpbKnJqYlZKQx5KWks2VnJmPmszLmJ7",
		"yc oauth":        "y0_" + "AgAAAAAAbcdEFGhijKLmnoPQrstUVwxYZ0123456",
		"yc api key":      "AQVN" + "1a2b3c4d5e6f7g8h9i0jKLMNOPqrstuvwx",
		"secret in text":  "export GITHUB_TOKEN=ghp_" + "aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789",
	}
	for name, s := range secrets {
		if !looksLikeSecret([]byte(s)) {
			t.Errorf("%s: expected secret, got clean: %q", name, s)
		}
	}

	clean := map[string]string{
		"prose":       "just some normal text to paste somewhere",
		"sha256":      "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
		"uuid":        "123e4567-e89b-12d3-a456-426614174000",
		"git hash":    "91ef839a2c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f",
		"public key":  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExample user@host",
		"yaml token":  "token: short",
		"url":         "https://github.com/AvengeMedia/DankMaterialShell",
		"kubectl cmd": "kubectl get pods -n kube-system",
	}
	for name, s := range clean {
		if looksLikeSecret([]byte(s)) {
			t.Errorf("%s: expected clean, got secret: %q", name, s)
		}
	}
}
