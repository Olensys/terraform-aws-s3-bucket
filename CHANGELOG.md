# Changelog

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare required_version and providers in examples/minimal

### Tests

- mark smoke runs, add tags contract run, drop unobservable cors claim

### Docs

- state that the 7-day multipart abort is a per-rule default

## 1.0.0

Initial release: private, encrypted, TLS-only S3 bucket as a thin wrapper over `terraform-aws-modules/s3-bucket/aws` 5.17.0, with optional versioning, lifecycle rules, CORS and a merged bucket policy.
