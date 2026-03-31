---
name: storage
description: "File storage and uploads. S3/R2, presigned URLs, image optimization, resumable uploads, virus scanning."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Agent
---

# /storage — File Storage & Uploads

Secure file uploads with S3/R2, image processing, CDN delivery.

## Usage

```
/storage setup                      # Set up S3/R2 + upload API
/storage upload                     # File upload component + API
/storage images                     # Image optimization
/storage presigned                  # Presigned URL flow
```

## Patterns

- Presigned URL upload (server never sees file bytes)
- File validation (type + size server-side)
- Image optimization with sharp (responsive variants)
- CDN delivery (CloudFront/Cloudflare)

## Rules

- ALWAYS use presigned URLs for large uploads
- Validate file type and size server-side
- Scope uploads to organization
- Set CORS on S3 bucket
- Clean up orphaned files
