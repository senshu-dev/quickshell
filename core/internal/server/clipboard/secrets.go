package clipboard

import (
	"regexp"
	"strings"
)

// Copies matching any of these are never written to history.
// ponytail: fixed pattern list, no entropy heuristic (false-positives on hashes/UUIDs); move to config if it needs per-user tuning.
var secretPatterns = regexp.MustCompile(`(?m)` + strings.Join([]string{
	`-----BEGIN [A-Z ]*PRIVATE KEY-----`,
	`\bgh[pousr]_[A-Za-z0-9]{36,}`,
	`\bgithub_pat_\w{22,}`,
	`\bglpat-[\w-]{20,}`,
	`\b(?:AKIA|ASIA)[0-9A-Z]{16}\b`,
	`\bxox[abprs]-[\w-]{10,}`,
	`\bsk-ant-[\w-]{20,}`,
	`\beyJ[\w-]+\.eyJ[\w-]+\.[\w-]+`,
	`client-key-data:\s*\S+`,
	`^\s*token:\s*\S{20,}`,
	`\bt1\.[\w.-]{50,}`,
	`\by0_[\w-]{30,}`,
	`\bAQVN[\w-]{30,}`,
}, "|"))

func looksLikeSecret(data []byte) bool {
	return secretPatterns.Match(data)
}
