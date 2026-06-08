# PreToolUse hook: blocks `gh` commands that write to GitHub (issue/pr create|comment|edit,
# gh api POST/PATCH/PUT, release/gist create) when the command text or any referenced
# body file (--body-file/-F/--input, including gh api field=@file) contains secret-like
# material. Exit 2 = block (stderr is fed back to the model). Exit 0 = allow.
# Policy: never put keys, passwords, or tokens on GitHub issues/PRs (Decision 77).

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $payload = $raw | ConvertFrom-Json
    $cmd = $payload.tool_input.command
    if (-not $cmd) { exit 0 }

    # Gate only GitHub-writing gh invocations; everything else passes untouched.
    $isGhWrite = ($cmd -match '(?i)\bgh\s+(issue|pr)\s+\S*\s*(create|comment|edit|close|reopen|review|merge)') -or
                 ($cmd -match '(?i)\bgh\s+api\b') -or
                 ($cmd -match '(?i)\bgh\s+(release|gist)\s+(create|edit|upload)')
    if (-not $isGhWrite) { exit 0 }
    # gh api: only gate write methods / field payloads
    if ($cmd -match '(?i)\bgh\s+api\b' -and
        $cmd -notmatch '(?i)(-X\s*|--method[=\s]*)(POST|PATCH|PUT)|--?(raw-)?field\b|-[fF]\b|--input\b' -and
        $cmd -notmatch '(?i)\bgh\s+(issue|pr|release|gist)\b') { exit 0 }

    # Collect text to scan: the command itself + contents of referenced body files.
    $texts = New-Object System.Collections.Generic.List[string]
    [void]$texts.Add([string]$cmd)
    $fileArgs = [regex]::Matches($cmd, '(?:--body-file|--input|-F|--field|--raw-field)[=\s]+(?:"([^"]+)"|''([^'']+)''|([^\s"'']+))')
    foreach ($m in $fileArgs) {
        $v = @($m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value) | Where-Object { $_ } | Select-Object -First 1
        if (-not $v -or $v -eq '-') { continue }
        if ($v -match '^[^=]+=@(.+)$') { $v = $matches[1] }      # gh api field=@file
        elseif ($v -match '^[^=]+=') { continue }                  # gh api field=literal (already in $cmd)
        $candidates = @($v)
        if ($v -match '^/([a-zA-Z])/(.*)$') { $candidates += "$($matches[1]):/$($matches[2])" }  # MSYS /c/x -> C:/x
        foreach ($p in $candidates) {
            if (Test-Path -LiteralPath $p -PathType Leaf) { [void]$texts.Add((Get-Content -LiteralPath $p -Raw)); break }
        }
    }

    $patterns = @(
        @{ n = 'JWT';                          r = 'eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}' },
        @{ n = 'long hex token (48+ chars)';   r = '(?<![0-9a-fA-F])(?<!sha256:)[0-9a-fA-F]{48,}' },
        @{ n = 'Bearer token';                 r = '\bBearer\s+[A-Za-z0-9._~+/=-]{16,}' },
        @{ n = 'GitHub token';                 r = '\bgh[pousr]_[A-Za-z0-9]{20,}\b' },
        @{ n = 'private key block';            r = '-----BEGIN [A-Z ]*PRIVATE KEY' },
        @{ n = 'Azure AccountKey / SAS sig';   r = '(AccountKey=|[?&;]sig=)[A-Za-z0-9%+/=]{20,}' },
        @{ n = 'credential assignment';        r = '\b(password|passwd|pwd|secret|api[_-]?key|client[_-]?secret|access[_-]?key|auth[_-]?secret|sas[_-]?token|connection[_-]?string)\b\s*[:=]\s*["'']?(?![<$%{*\[])[^\s"'';,]{6,}' },
        @{ n = 'known env secret with value';  r = '\b(AUTH_SECRET|STRAPI_API_TOKEN|AUTH_ENTRA_CLIENT_SECRET)\s*[:=]\s*(?![<$%{*\[])\S{6,}' }
    )

    foreach ($t in $texts) {
        foreach ($p in $patterns) {
            if ($t -match $p.r) {
                [Console]::Error.WriteLine("BLOCKED by gh-secret-scan hook: potential secret ($($p.n)) detected in a GitHub-bound gh command or its body file. Never post keys, passwords, or tokens to GitHub issues/PRs. Redact the value (reference the env var NAME or write [REDACTED]) and retry.")
                exit 2
            }
        }
    }
    exit 0
}
catch {
    # Fail open: a broken hook must not wedge every gh call; the skill-level redaction rules still apply.
    [Console]::Error.WriteLine("gh-secret-scan hook error (allowing call): $($_.Exception.Message)")
    exit 0
}
