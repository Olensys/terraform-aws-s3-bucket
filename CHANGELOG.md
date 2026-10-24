# Changelog

## 1.1.0

### Behaviour changes

- `versioning_enabled` now defaults to `null`, which resolves to enabled when `context.environment` is `prod` and disabled otherwise. A prod bucket that must stay unversioned needs `versioning_enabled = false`; existing prod buckets will have versioning enabled on the next apply unless that is set.

### Fixes

- Versioning default follows the environment (`coalesce(var.versioning_enabled, var.context.environment == "prod")`).

### Tests

- Added prod default on, dev default off and explicit-override-wins runs.

### Docs

- README Opinions and Usage updated; Usage shows the naming module.

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
