---
profile: compose-terraform
role: infra
check-root: posix
status: written
---

# `compose-terraform` (infra; variants `aws`, `azure`, `gcp`)

Everything in `compose-northflank` except `src/iac/northflank/`, which is replaced by:

- **Tool**: OpenTofu or Terraform (ask; OpenTofu keeps the licence open, both read the
  same files). Pin the version in `src/iac/.terraform-version` (or `.opentofu-version`).
- **Source**: `src/iac/<cloud>/modules/{network,database,cache,storage,registry,secrets,app}/`
  and `src/iac/<cloud>/envs/{staging,prod}/` (`main.tf`, `backend.tf`, `*.tfvars`; the
  `.terraform.lock.hcl` is committed per env). Image digests come from
  `src/environments/<env>.yaml`.
- **Cloud mapping** (confirm current service names at scaffold time):

  | Need | `aws` | `azure` | `gcp` |
  |---|---|---|---|
  | Containers | ECS Fargate + ALB | Container Apps | Cloud Run |
  | PostgreSQL | RDS for PostgreSQL | Database for PostgreSQL – Flexible Server | Cloud SQL for PostgreSQL |
  | Redis / Valkey | ElastiCache | Azure Managed Redis | Memorystore |
  | Object storage | S3 | Blob Storage | Cloud Storage |
  | Registry | ECR | Container Registry | Artifact Registry |
  | Secrets | Secrets Manager | Key Vault | Secret Manager |
  | State backend | S3 (lockfile locking) | Storage account | GCS |
  | CI auth | GitHub OIDC → IAM role | GitHub OIDC → federated identity | Workload Identity Federation |

- **Rules**: no long-lived cloud keys in CI; the app's database role is not the owner and
  has no `BYPASSRLS`; the migrate image runs as a one-off task before app rollout; realtime
  needs WebSocket-capable ingress (all three rows above are).
- **Tests**: `tofu|terraform fmt -check -recursive`, `validate` per env, `tflint`, a config
  scan (Checkov or Trivy), and `tests/iac/<cloud>/*.tftest.hcl` run with
  `-test-directory`.
- **CI**: plan on pull request (plan posted as a comment), apply on merge per environment
  with a required approval for prod.
- **Verify**: fmt, validate, tflint, scan; `plan` only if the user has credentials and
  asks. Never `apply` from this skill.
