# Site checker: lang, absolute hreflang (self, counterpart, x-default), canonical, local links/fragments/assets, lang switch, and required section ids per page (home pages: home work contact; about pages: contact).
# Game pages (games/, pt/games/): ids overview, role, challenges, results in order; one h1; provisional text blocks are counted (NOTE) and fail with -Publish.
# Usage (from repo root): powershell -ExecutionPolicy Bypass -File tools/check-site.ps1 [-Publish]
param([switch]$Publish)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skip = @('.git', '.superpowers', 'docs', 'tools')
$siteUrl = 'https://karolinaschmitt.github.io/'
$script:failures = New-Object System.Collections.ArrayList
$script:notes = New-Object System.Collections.ArrayList
$script:phTotal = 0
$script:phPages = 0

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
    if ($h.StartsWith($siteUrl)) { $h = '/' + $h.Substring($siteUrl.Length) }
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

# The EN file for a page: itself for EN pages, the pt/-stripped path for PT pages.
function Get-EnVersion($full, $rel) {
    if ($rel.StartsWith('pt/')) { return Join-Path $root ($rel.Substring(3).Replace('/', [string][char]92)) }
    return $full
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

    # 2. hreflang: self, counterpart (back-link in the right language), x-default -> EN version
    $want = 'pt-BR'
    if ($isPt) { $want = 'en' }
    $alt = $null
    $self = $null
    $xdef = $null
    foreach ($a in (Get-Alternates $html)) {
        if ($a.hreflang -ieq $want) { $alt = $a }
        elseif ($a.hreflang -ieq $expected) { $self = $a }
        elseif ($a.hreflang -ieq 'x-default') { $xdef = $a }
    }
    $target = $null
    if (-not $self) {
        Add-Fail $rel "missing <link rel=`"alternate`" hreflang=`"$expected`"> (self reference)"
    } else {
        $st = Test-Local $f.FullName $self.href
        if ($st -ne 'ok') { Add-Fail $rel "hreflang=$expected self reference does not resolve ($st): $($self.href)" }
        elseif ($script:found -cne $f.FullName) { Add-Fail $rel "hreflang=$expected does not point to this page: $($self.href)" }
    }
    if (-not $xdef) {
        Add-Fail $rel "missing <link rel=`"alternate`" hreflang=`"x-default`">"
    } else {
        $st = Test-Local $f.FullName $xdef.href
        if ($st -ne 'ok') { Add-Fail $rel "x-default does not resolve ($st): $($xdef.href)" }
        elseif ($script:found -cne (Get-EnVersion $f.FullName $rel)) { Add-Fail $rel "x-default must point to the EN version: $($xdef.href)" }
    }
    if (-not $alt) {
        Add-Fail $rel "missing <link rel=`"alternate`" hreflang=`"$want`">"
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
            $backLang = $false
            foreach ($b in (Get-Alternates $thtml)) {
                $bf = Resolve-Safe $target $b.href
                if (-not $bf) { continue }
                $bt = Find-Target $bf
                if ($bt -and ($bt -ceq $f.FullName)) {
                    if ($b.hreflang -ieq $expected) { $back = $true; break }
                    elseif ($b.hreflang -ine 'x-default') { $backLang = $true }
                }
                if ($bt -and ($bt -ieq $f.FullName)) { $backCase = $true }
            }
            if ($backCase -and -not $back -and -not $backLang) {
                Add-Fail $rel "case mismatch: back-link from $(Get-Rel $target) points to a differently-cased path"
            } elseif ($backLang -and -not $back) {
                Add-Fail $rel "back-link from $(Get-Rel $target) has the wrong hreflang (expected $expected)"
            } elseif (-not $back) {
                Add-Fail $rel "hreflang target $(Get-Rel $target) does not link back"
            }
        }
    }
    # 2b. visible language switch must match the hreflang counterpart
    $sw = $null
    foreach ($m in [regex]::Matches($html, '<a\b[^>]*>', 'IgnoreCase')) {
        $cls = Get-Attr $m.Value 'class'
        if ($cls -and (($cls -split '\s+') -contains 'lang') -and (Get-Attr $m.Value 'href')) { $sw = Get-Attr $m.Value 'href'; break }
    }
    if (-not $sw) {
        Add-Fail $rel "missing language switch link"
    } elseif ($target) {
        $st = Test-Local $f.FullName $sw
        if ($st -ne 'ok' -or $script:found -cne $target) { Add-Fail $rel "lang switch does not match hreflang counterpart" }
    }
    # 2c. canonical points to this page
    $canon = $null
    foreach ($m in [regex]::Matches($html, '<link\b[^>]*>', 'IgnoreCase')) {
        $r = Get-Attr $m.Value 'rel'
        if ($r -and (($r -split '\s+') -contains 'canonical')) { $canon = Get-Attr $m.Value 'href'; break }
    }
    if (-not $canon) {
        Add-Fail $rel "missing rel=canonical"
    } else {
        $st = Test-Local $f.FullName $canon
        if ($st -ne 'ok' -or $script:found -cne $f.FullName) { Add-Fail $rel "canonical does not point to this page: $canon" }
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
        elseif ($st -eq 'ok' -and $i -gt 0 -and $path[$i] -eq '#' -and $script:found -match '\.html?$') {
            $frag = [Uri]::UnescapeDataString($path.Substring($i + 1))
            $th = [IO.File]::ReadAllText($script:found, [Text.Encoding]::UTF8)
            if ($frag -ne '' -and -not [regex]::IsMatch($th, "(?<![\w-])id\s*=\s*[`"']$([regex]::Escape($frag))[`"']")) { Add-Fail $rel "missing fragment $val" }
        }
    }

    # 3b. same-page #fragment links must have a matching id
    foreach ($m in [regex]::Matches($html, '(?<![\w-])href\s*=\s*"#([^"]+)"', 'IgnoreCase')) {
        $frag = $m.Groups[1].Value
        if (-not [regex]::IsMatch($html, "(?<![\w-])id\s*=\s*[`"']$([regex]::Escape($frag))[`"']")) { Add-Fail $rel "missing fragment #$frag" }
    }

    # 4. required section ids per page
    $requiredIds = @()
    if ($rel -eq 'index.html' -or $rel -eq 'pt/index.html') { $requiredIds = @('home', 'work', 'contact') }
    elseif ($rel -eq 'about.html' -or $rel -eq 'pt/about.html') { $requiredIds = @('contact') }
    foreach ($id in $requiredIds) {
        if ($html -cnotmatch "(?<![\w-])id\s*=\s*[`"']$id[`"']") {
            Add-Fail $rel "missing section id=`"$id`""
        }
    }

    # 5. game pages (games/, pt/games/): template ids in order, one h1. HTML comments are ignored.
    $clean = [regex]::Replace($html, '(?s)<!--.*?-->', '')
    if ($rel -like 'games/*' -or $rel -like 'pt/games/*') {
        $pos = @()
        foreach ($id in @('overview', 'role', 'challenges', 'results')) {
            $mm = [regex]::Match($clean, "(?<![\w-])id\s*=\s*[`"']$id[`"']")
            if (-not $mm.Success) { Add-Fail $rel "missing section id=`"$id`""; $pos += -1 } else { $pos += $mm.Index }
        }
        if (-not ($pos -contains -1) -and -not (($pos[0] -lt $pos[1]) -and ($pos[1] -lt $pos[2]) -and ($pos[2] -lt $pos[3]))) {
            Add-Fail $rel 'section ids must be in order: overview, role, challenges, results'
        }
        $h1 = [regex]::Matches($clean, '<h1[\s>]', 'IgnoreCase').Count
        if ($h1 -ne 1) { Add-Fail $rel "expected exactly one <h1>, found $h1" }
    }

    # 6. provisional text, three independent signals on every page (comments ignored)
    $cData = [regex]::Matches($clean, '(?<![\w-])data-placeholder(?![\w-])').Count
    $cClass = 0
    $cBadgeEl = 0
    foreach ($m in [regex]::Matches($clean, '(?<![\w-])class\s*=\s*(?:"([^"]*)"|''([^'']*)'')', 'IgnoreCase')) {
        $toks = ($m.Groups[1].Value + ' ' + $m.Groups[2].Value) -split '\s+'
        if ($toks -contains 'placeholder') { $cClass++ }
        if ($toks -contains 'ph-badge') { $cBadgeEl++ }
    }
    $cBadgeTxt = [regex]::Matches($clean, 'Provisional text|Texto provis.rio').Count
    $cBadge = [Math]::Max($cBadgeEl, $cBadgeTxt)
    $ph = [Math]::Max($cData, [Math]::Max($cClass, $cBadge))
    if ($cData -ne $cClass -or $cData -ne $cBadge) {
        Add-Fail $rel "inconsistent provisional markers (data-placeholder=$cData, class=$cClass, badge=$cBadge)"
    }
    if ($ph -gt 0) {
        [void]$script:notes.Add("NOTE: ${rel}: $ph provisional text block(s)")
        $script:phTotal += $ph
        $script:phPages++
        if ($Publish) { Add-Fail $rel "provisional text ($ph)" }
    }}

foreach ($line in $script:failures) { Write-Output $line }
foreach ($line in $script:notes) { Write-Output $line }
if ($script:phTotal -gt 0) { Write-Output "NOTE: $($script:phTotal) provisional text block(s) in $($script:phPages) page(s)" }
if ($script:failures.Count -eq 0) {
    Write-Output 'OK'
    exit 0
}
Write-Output "FAILED $($script:failures.Count)"
exit 1
