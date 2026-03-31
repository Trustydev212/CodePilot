#!/bin/bash
# safety-guard.sh - Comprehensive security guard for bash commands
# Used in PreToolUse hook for Bash tool
# 100+ protection patterns covering: destructive ops, secret exfiltration,
# database attacks, git force ops, permission abuse, network attacks, crypto mining

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# ============================================================
# CATEGORY 1: DESTRUCTIVE FILE OPERATIONS
# ============================================================
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?(/|~|\.\.|/etc|/usr|/var|/boot|/sys|/proc|\$HOME)'; then
  echo "BLOCKED: Destructive rm targeting system/home directory" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*\s+-[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*\s+-[a-zA-Z]*r'; then
  if echo "$COMMAND" | grep -qE '(/|\*|~|\.\.|/etc|/usr|/var|\$HOME)'; then
    echo "BLOCKED: Recursive force delete on dangerous path" >&2; exit 2
  fi
fi
if echo "$COMMAND" | grep -qE 'mkfs\.|wipefs|shred\s|dd\s+if=.+of=/dev'; then
  echo "BLOCKED: Disk/filesystem destructive operation" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE '>\s*/dev/sd|>\s*/dev/nvme|>\s*/dev/vd'; then
  echo "BLOCKED: Writing directly to block device" >&2; exit 2
fi

# ============================================================
# CATEGORY 2: FORK BOMBS & RESOURCE EXHAUSTION
# ============================================================
if echo "$COMMAND" | grep -qE ':\(\)\{|:\(\)\s*\{|\.(){|fork\s*bomb|while\s+true.*fork|:()\s*\{'; then
  echo "BLOCKED: Fork bomb detected" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'yes\s*\|.*>|cat\s+/dev/urandom.*>|head\s+-c\s+[0-9]{10,}'; then
  echo "BLOCKED: Resource exhaustion attack" >&2; exit 2
fi

# ============================================================
# CATEGORY 3: SECRET EXFILTRATION & DATA THEFT
# ============================================================

# Block reading sensitive files and piping to network
if echo "$COMMAND" | grep -qiE '(cat|head|tail|less|more|bat|xxd|strings)\s+.*\.(env|key|pem|p12|pfx|jks|keystore|secret|credentials|token)'; then
  if echo "$COMMAND" | grep -qiE '\|\s*(curl|wget|nc|netcat|ncat|socat|ssh|scp|rsync|ftp|tftp|telnet)'; then
    echo "BLOCKED: Piping secrets to network command" >&2; exit 2
  fi
fi

# Block direct upload of secrets
if echo "$COMMAND" | grep -qiE '(curl|wget)\s+.*(-d|--data|--data-binary|--upload-file|-F)\s+.*\.(env|key|pem|secret|credentials)'; then
  echo "BLOCKED: Uploading secret file to remote" >&2; exit 2
fi

# Block encoding secrets for exfiltration
if echo "$COMMAND" | grep -qiE '(base64|openssl\s+enc|gpg\s+-e)\s+.*\.(env|key|pem|secret)'; then
  if echo "$COMMAND" | grep -qiE '\|\s*(curl|wget|nc)'; then
    echo "BLOCKED: Encoding and exfiltrating secrets" >&2; exit 2
  fi
fi

# Block DNS exfiltration
if echo "$COMMAND" | grep -qiE '(dig|nslookup|host)\s+.*\$\(cat.*\.(env|key|pem)\)'; then
  echo "BLOCKED: DNS exfiltration of secrets" >&2; exit 2
fi

# ============================================================
# CATEGORY 4: CREDENTIAL & KEY FILE ACCESS
# ============================================================

# AWS credentials
if echo "$COMMAND" | grep -qiE 'cat\s+.*\.aws/(credentials|config)'; then
  echo "BLOCKED: Reading AWS credentials" >&2; exit 2
fi

# SSH keys
if echo "$COMMAND" | grep -qiE '(cat|cp|scp|rsync)\s+.*\.ssh/(id_rsa|id_ed25519|id_ecdsa|authorized_keys)'; then
  if echo "$COMMAND" | grep -qiE '\|\s*(curl|wget|nc|ssh|scp)'; then
    echo "BLOCKED: Exfiltrating SSH keys" >&2; exit 2
  fi
fi

# GCP/Azure/Cloud credentials
if echo "$COMMAND" | grep -qiE 'cat\s+.*(gcloud|azure|credentials\.json|service.account\.json|key\.json)'; then
  echo "BLOCKED: Reading cloud provider credentials" >&2; exit 2
fi

# Docker secrets
if echo "$COMMAND" | grep -qiE 'docker\s+secret\s+inspect|cat\s+/run/secrets/'; then
  echo "BLOCKED: Accessing Docker secrets" >&2; exit 2
fi

# Kubernetes secrets
if echo "$COMMAND" | grep -qiE 'kubectl\s+get\s+secret.*-o\s+(json|yaml|jsonpath)'; then
  echo "BLOCKED: Dumping Kubernetes secrets" >&2; exit 2
fi

# ============================================================
# CATEGORY 5: DATABASE DESTRUCTIVE OPERATIONS
# ============================================================
if echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA|INDEX|VIEW|TRIGGER|FUNCTION|PROCEDURE)'; then
  echo "BLOCKED: DROP operation. Use migrations instead." >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'TRUNCATE\s+'; then
  echo "BLOCKED: TRUNCATE operation. Use DELETE with WHERE clause." >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'DELETE\s+FROM\s+\w+\s*$|DELETE\s+FROM\s+\w+\s*;|DELETE\s+FROM.*WHERE\s+1\s*=\s*1'; then
  echo "BLOCKED: DELETE without proper WHERE clause" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'ALTER\s+TABLE.*DROP\s+COLUMN'; then
  echo "WARNING: Dropping column. Ensure code is updated first." >&2
fi

# ============================================================
# CATEGORY 6: GIT DANGEROUS OPERATIONS
# ============================================================
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force\b' && ! echo "$COMMAND" | grep -qE '\-\-force-with-lease'; then
  echo "BLOCKED: git push --force. Use --force-with-lease instead." >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard\s+(origin/main|origin/master|HEAD~[5-9]|HEAD~[1-9][0-9])'; then
  echo "BLOCKED: Dangerous git reset (too many commits or to remote main)" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+clean\s+-[a-zA-Z]*f[a-zA-Z]*d'; then
  echo "BLOCKED: git clean -fd removes untracked files and directories" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+checkout\s+--\s+\.'; then
  echo "BLOCKED: git checkout -- . discards all unstaged changes" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+branch\s+-D\s+(main|master|develop|staging|production)'; then
  echo "BLOCKED: Deleting protected branch" >&2; exit 2
fi

# ============================================================
# CATEGORY 7: PERMISSION & OWNERSHIP
# ============================================================
if echo "$COMMAND" | grep -qE 'chmod\s+(777|666|a\+rwx|o\+w)'; then
  echo "BLOCKED: Insecure permissions (world-writable). Use specific permissions." >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'chown\s+-R\s+root'; then
  echo "BLOCKED: Recursive chown to root on project files" >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'chmod\s+-R\s+777'; then
  echo "BLOCKED: Recursive world-writable permissions" >&2; exit 2
fi

# ============================================================
# CATEGORY 8: NETWORK & REVERSE SHELL
# ============================================================
if echo "$COMMAND" | grep -qiE '(bash|sh|zsh)\s+-i\s+.*>/dev/tcp|/dev/udp'; then
  echo "BLOCKED: Reverse shell detected" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'nc\s+-[a-zA-Z]*l[a-zA-Z]*.*-e\s+(bash|sh|/bin)'; then
  echo "BLOCKED: Netcat reverse shell" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'python.*socket.*connect.*subprocess|perl.*socket.*exec'; then
  echo "BLOCKED: Scripted reverse shell" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'curl\s+.*\|\s*(bash|sh|python|perl|ruby|node)'; then
  echo "BLOCKED: Piping remote script to interpreter (curl | bash)" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'wget\s+.*-O\s*-\s*\|\s*(bash|sh|python)'; then
  echo "BLOCKED: Piping remote script to interpreter (wget | bash)" >&2; exit 2
fi

# ============================================================
# CATEGORY 9: CRYPTO MINING & MALWARE
# ============================================================
if echo "$COMMAND" | grep -qiE '(xmrig|minerd|cpuminer|cgminer|bfgminer|ethminer|stratum\+)'; then
  echo "BLOCKED: Cryptocurrency miner detected" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'curl.*\|\s*bash.*install.*miner|wget.*miner'; then
  echo "BLOCKED: Downloading mining software" >&2; exit 2
fi

# ============================================================
# CATEGORY 10: SYSTEM MANIPULATION
# ============================================================
if echo "$COMMAND" | grep -qiE '(shutdown|reboot|halt|poweroff|init\s+[0-6])'; then
  echo "BLOCKED: System shutdown/reboot command" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'kill\s+-9\s+-1|killall\s+-9'; then
  echo "BLOCKED: Killing all processes" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'crontab\s+-r|crontab\s+/dev/null'; then
  echo "BLOCKED: Removing all cron jobs" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE '(iptables|ufw)\s+.*-F|iptables\s+.*ACCEPT.*all'; then
  echo "BLOCKED: Flushing firewall rules" >&2; exit 2
fi

# ============================================================
# CATEGORY 11: PACKAGE MANAGER ABUSE
# ============================================================
if echo "$COMMAND" | grep -qiE 'npm\s+publish\s*$|npm\s+unpublish'; then
  echo "BLOCKED: npm publish/unpublish without explicit scope" >&2; exit 2
fi
if echo "$COMMAND" | grep -qiE 'pip\s+install\s+.*--break-system-packages'; then
  echo "BLOCKED: pip install with --break-system-packages" >&2; exit 2
fi

# All checks passed
exit 0
