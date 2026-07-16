# Bulk-fix all PS5 compatibility issues across the codebase
$Root = "C:\AI\GOD-OPENCODE"

function Fix-File($path) {
    $c = Get-Content $path -Raw -Encoding UTF8
    $orig = $c
    # utf8NoBOM -> UTF8
    $c = $c -replace '-Encoding UTF8', '-Encoding UTF8'
    $c = $c -replace "-Encoding UTF8", '-Encoding UTF8'
    # em dash (Unicode 0x2014) -> hyphen
    $c = $c -replace [char]0x2014, '-'
    # null coalescing ?? operator -> handled elsewhere
    if ($c -ne $orig) {
        Set-Content $path $c -Encoding UTF8
        Write-Host "[FIXED] $path"
    }
}

Get-ChildItem $Root -Recurse -Include "*.ps1","*.md","*.json" |
    Where-Object { $_.FullName -notmatch '\\\.git\\' } |
    ForEach-Object { Fix-File $_.FullName }

Write-Host "Done."

