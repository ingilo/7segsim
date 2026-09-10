# Builds dist\7-Segment Logic Lab.exe with the C# compiler that ships with Windows (.NET Framework 4).
# Run again after changing index.html:  powershell -ExecutionPolicy Bypass -File app\build.ps1
$ErrorActionPreference = 'Stop'
$appDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$projDir = Split-Path -Parent $appDir
$icon    = Join-Path $appDir 'icon.ico'
$distDir = Join-Path $projDir 'dist'
$out     = Join-Path $distDir '7-Segment Logic Lab.exe'

$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) { $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe' }
if (-not (Test-Path $csc)) { throw 'C# compiler (csc.exe) from .NET Framework 4 was not found.' }

# ---- icon: a red 7-segment digit on a dark rounded square (PNG-compressed .ico) ----
if (-not (Test-Path $icon)) {
    Add-Type -AssemblyName System.Drawing
    function New-IconPng([int]$size) {
        $bmp = New-Object System.Drawing.Bitmap $size, $size
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.Clear([System.Drawing.Color]::Transparent)
        $s = [single]($size - 1); $r = [single]($size * 0.2)
        $bg = New-Object System.Drawing.Drawing2D.GraphicsPath
        $bg.AddArc(0, 0, 2 * $r, 2 * $r, 180, 90)
        $bg.AddArc($s - 2 * $r, 0, 2 * $r, 2 * $r, 270, 90)
        $bg.AddArc($s - 2 * $r, $s - 2 * $r, 2 * $r, 2 * $r, 0, 90)
        $bg.AddArc(0, $s - 2 * $r, 2 * $r, 2 * $r, 90, 90)
        $bg.CloseFigure()
        $g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 22, 22, 22))), $bg)

        $W = $size * 0.40; $H = $size * 0.66; $t = [Math]::Max(2.0, $size * 0.105); $ht = $t / 2
        $ox = ($size - $W) / 2; $oy = ($size - $H) / 2; $gap = $size * 0.012
        function P($x, $y) { New-Object System.Drawing.PointF ([single]$x), ([single]$y) }
        function HSeg($x, $y, $len) { ,@((P ($x+$gap) $y), (P ($x+$gap+$ht) ($y-$ht)), (P ($x+$len-$gap-$ht) ($y-$ht)), (P ($x+$len-$gap) $y), (P ($x+$len-$gap-$ht) ($y+$ht)), (P ($x+$gap+$ht) ($y+$ht))) }
        function VSeg($x, $y, $len) { ,@((P $x ($y+$gap)), (P ($x+$ht) ($y+$gap+$ht)), (P ($x+$ht) ($y+$len-$gap-$ht)), (P $x ($y+$len-$gap)), (P ($x-$ht) ($y+$len-$gap-$ht)), (P ($x-$ht) ($y+$gap+$ht))) }
        $segs = @(
            (HSeg $ox $oy $W), (VSeg ($ox+$W) $oy ($H/2)), (VSeg ($ox+$W) ($oy+$H/2) ($H/2)),
            (HSeg $ox ($oy+$H) $W), (VSeg $ox ($oy+$H/2) ($H/2)), (VSeg $ox $oy ($H/2)), (HSeg $ox ($oy+$H/2) $W))
        $on  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 59, 48))
        $off = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 70, 28, 28))
        for ($i = 0; $i -lt 7; $i++) {
            $brush = $on; if ($i -eq 6) { $brush = $off }
            $g.FillPolygon($brush, [System.Drawing.PointF[]]$segs[$i])
        }
        $g.Dispose()
        $ms = New-Object System.IO.MemoryStream
        $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        return ,$ms.ToArray()
    }
    $sizes = @(16, 32, 48, 256)
    $pngs = @(); foreach ($sz in $sizes) { $pngs += ,(New-IconPng $sz) }
    $bw = New-Object System.IO.BinaryWriter ([System.IO.File]::Create($icon))
    $bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$sizes.Count)
    $offset = 6 + 16 * $sizes.Count
    for ($i = 0; $i -lt $sizes.Count; $i++) {
        $dim = $sizes[$i]; if ($dim -ge 256) { $dim = 0 }
        $bw.Write([byte]$dim); $bw.Write([byte]$dim); $bw.Write([byte]0); $bw.Write([byte]0)
        $bw.Write([uint16]1); $bw.Write([uint16]32)
        $bw.Write([uint32]$pngs[$i].Length); $bw.Write([uint32]$offset)
        $offset += $pngs[$i].Length
    }
    foreach ($d in $pngs) { $bw.Write([byte[]]$d) }
    $bw.Close()
    Write-Host "Created $icon"
}

New-Item -ItemType Directory -Force $distDir | Out-Null
& $csc /nologo /target:winexe /optimize+ "/out:$out" "/win32icon:$icon" "/resource:$(Join-Path $projDir 'index.html'),index.html" /r:System.Windows.Forms.dll (Join-Path $appDir 'Launcher.cs')
if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
Write-Host "Built $out"
