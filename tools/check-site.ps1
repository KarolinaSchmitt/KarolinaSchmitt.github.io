# Site checker: lang, hreflang pairs, local links/assets, and the five home section ids (home work about experience contact).
# Usage (from repo root): powershell -ExecutionPolicy Bypass -File tools/check-site.ps1
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skip = @('.git', '.superpowers', 'docs', 'tools')
$sectionIds = @('home', 'work', 'about', 'experience', 'contact')
$script:failures = New-Object System.Collections.ArrayList

function Add-Fail($page, $reason) {
    [void]$script:failures.Add("FAIL: ${page}: $reason")
}

function Get-Rel($full) {
    $r = $full.Substring($root.Length).TrimStart('\', '/')
    return $r.Replace([string][char]92, '/')
}

# Resolve an href relative to a page's folder (root-relative if it starts with /).
function Resolve-Href($pageFull, $href) {
    $h = $href
    $i = $h.IndexOfAny([char[]]'?#')
    if ($i -ge 0) { $h = $h.Substring(0, $i) }
    $h = [Uri]::UnescapeDataString($h)
    if ($h.StartsWith('/')) {
        $base = $root
        $h = $h.TrimStart('/')
    } else {
        $base = Split-Path -Parent $pageFull
    }
    $h = $h.Replace('/', [string][char]92)
    return [IO.Path]::GetFullPath((Join-Path $base $h))
}

# A target "exists" if it is a file, or a folder containing index.html.
function Find-Target($full) {
    if (Test-Path -LiteralPath $full -PathType Leaf) { return $full }
    if (Test-Path -LiteralPath $full -PathType Container) {
        $idx = Join-Path $full 'index.html'
        if (Test-Path -LiteralPath $idx -PathType Leaf) { return $idx }
    }
    return $null
}

# Resolve without throwing; $null when the href has path-invalid characters.
function Resolve-Safe($pageFull, $href) {
    try { return Resolve-Href $pageFull $href } catch { return $null }
}

# True when every path segment matches the on-disk name exactly (GitHub Pages is case-sensitive).
function Test-ExactCase($full) {
    if (-not $full.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    $cur = $root
    foreach ($seg in $full.Substring($root.Length).Split([char[]]@([char]92, [char]47), [StringSplitOptions]::RemoveEmptyEntries)) {
        $names = @(Get-ChildItem -LiteralPath $cur -Force | ForEach-Object { $_.Name })
        if (-not ($names -ccontains $seg)) { return $false }
        $cur = Join-Path $cur $seg
    }
    return $true
}

# Returns 'ok', 'missing', 'case' or 'invalid' for an href on a page; $script:found holds the file.
function Test-Local($pageFull, $href) {
    $script:found = $null
    $full = Resolve-Safe $pageFull $href
    if (-not $full) { return 'invalid' }
    $found = Find-Target $full
    if (-not $found) { return 'missing' }
    if (-not (Test-ExactCase $found)) { return 'case' }
    $script:found = $found
    return 'ok'
}

function Get-Attr($tag, $name) {
    $m = [regex]::Match($tag, "(?<![\w-])$name\s*=\s*(?:`"([^`"]*)`"|'([^']*)')", 'IgnoreCase')
    if (-not $m.Success) { return $null }
    if ($m.Groups[1].Success) { return $m.Groups[1].Value }
    return $m.Groups[2].Value
}

# Returns @(@{ hreflang=..; href=.. }) for <link rel="alternate" hreflang=.. href=..>
function Get-Alternates($html) {
    $out = @()
    foreach ($m in [regex]::Matches($html, '<link\b[^>]*>', 'IgnoreCase')) {
        $tag = $m.Value
        $rel = Get-Attr $tag 'rel'
        $hl = Get-Attr $tag 'hreflang'
        $href = Get-Attr $tag 'href'
        if ($rel -and ($rel -match '(^|\s)alternate(\s|$)') -and $hl -and $href) {
            $out += , @{ hreflang = $hl; href = $href }
        }
    }
    return $out
}

$files = Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.html' | Where-Object {
    $rel = Get-Rel $_.FullName
    $first = $rel.Split('/')[0]
    -not ($skip -contains $first)
} | Sort-Object FullName

foreach ($f in $files) {
    $rel = Get-Rel $f.FullName
    $isPt = $rel.StartsWith('pt/')
    $html = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8)

    # 1. lang attribute
    $expected = 'en'
    if ($isPt) { $expected = 'pt-BR' }
    $lm = [regex]::Match($html, '<html\b[^>]*?(?<![\w-])lang\s*=\s*["'']([^"'']*)["'']', 'IgnoreCase')
    if (-not $lm.Success) {
        Add-Fail $rel "missing lang attribute on <html> (expected $expected)"
    } elseif ($lm.Groups[1].Value -ne $expected) {
        Add-Fail $rel "lang is '$($lm.Groups[1].Value)', expected '$expected'"
    }

    # 2. hreflang counterpart
    $want = 'pt-BR'
    if ($isPt) { $want = 'en' }
    $alt = $null
    foreach ($a in (Get-Alternates $html)) {
        if ($a.hreflang -ieq $want) { $alt = $a; break }
    }
    if (-not $alt) {
        Add-Fail $rel "missing <link rel=`"alternate`" hreflang=`"$want`">"
    } elseif ($alt.href -match '^(https?:|//)') {
        Add-Fail $rel "hreflang=$want href '$($alt.href)' must be a relative path"
    } else {
        $st = Test-Local $f.FullName $alt.href
        $target = $script:found
        if ($st -eq 'invalid') {
            Add-Fail $rel "invalid link: $($alt.href)"
        } elseif ($st -eq 'case') {
            Add-Fail $rel "case mismatch: $($alt.href)"
        } elseif ($st -eq 'missing') {
            Add-Fail $rel "hreflang=$want target not found: $($alt.href)"
        } else {
            $thtml = [IO.File]::ReadAllText($target, [Text.Encoding]::UTF8)
            $back = $false
            $backCase = $false
            foreach ($b in (Get-Alternates $thtml)) {
                if ($b.href -match '^(https?:|//)') { continue }
                $bf = Resolve-Safe $target $b.href
                if (-not $bf) { continue }
                $bt = Find-Target $bf
                if ($bt -and ($bt -ceq $f.FullName)) { $back = $true; break }
                if ($bt -and ($bt -ieq $f.FullName)) { $backCase = $true }
            }
            if ($backCase -and -not $back) {
                Add-Fail $rel "case mismatch: back-link from $(Get-Rel $target) points to a differently-cased path"
            } elseif (-not $back) {
                Add-Fail $rel "hreflang target $(Get-Rel $target) does not link back"
            }
        }
    }
    # 3. local href/src/poster targets exist
    $seen = @{}
    foreach ($m in [regex]::Matches($html, '(?<![\w-])(?:href|src|poster)\s*=\s*(?:"([^"]*)"|''([^'']*)'')', 'IgnoreCase')) {
        $val = $m.Groups[1].Value
        if (-not $m.Groups[1].Success) { $val = $m.Groups[2].Value }
        $val = $val.Trim()
        if ($val -eq '' -or $val -match '^([a-zA-Z][a-zA-Z0-9+.-]*:|#|//)') { continue }
        if ($seen.ContainsKey($val)) { continue }
        $seen[$val] = $true
        $path = $val
        $i = $path.IndexOfAny([char[]]'?#')
        if ($i -eq 0) { continue }
        $st = Test-Local $f.FullName $val
        if ($st -eq 'invalid') { Add-Fail $rel "invalid link: $val" }
        elseif ($st -eq 'case') { Add-Fail $rel "case mismatch: $val" }
        elseif ($st -eq 'missing') { Add-Fail $rel "file not found: $val" }
    }

    # 4. section ids on the two home pages
    if ($rel -eq 'index.html' -or $rel -eq 'pt/index.html') {
        foreach ($id in $sectionIds) {
            if ($html -notmatch "(?<![\w-])id\s*=\s*[`"']$id[`"']") {
                Add-Fail $rel "missing section id=`"$id`""
            }
        }
    }
}

foreach ($line in $script:failures) { Write-Output $line }
if ($script:failures.Count -eq 0) {
    Write-Output 'OK'
    exit 0
}
Write-Output "FAILED $($script:failures.Count)"
exit 1
