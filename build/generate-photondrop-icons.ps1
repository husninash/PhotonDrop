Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\MyBook Army\.gemini\antigravity-ide\brain\144a024f-df68-4e7d-bbff-8512e9dd6f41\photondrop_app_icon_1789185206744.jpg"
$publicDir = "c:\Decimen\decimen-optical-transfer\public"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)

# The optical circle is centered at x=512, y=475, with radius approx 410px
# We crop a 880x880 region centered at (512, 475) to frame the glowing lens aperture beautifully
$cropSize = 880
$cropX = [int](512 - ($cropSize / 2))
$cropY = [int](475 - ($cropSize / 2))
if ($cropX -lt 0) { $cropX = 0 }
if ($cropY -lt 0) { $cropY = 0 }

$cropRect = [System.Drawing.Rectangle]::new($cropX, $cropY, $cropSize, $cropSize)
$cropped = New-Object System.Drawing.Bitmap $cropSize, $cropSize
$gCrop = [System.Drawing.Graphics]::FromImage($cropped)
$gCrop.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gCrop.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gCrop.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gCrop.DrawImage($src, [System.Drawing.Rectangle]::new(0, 0, $cropSize, $cropSize), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$gCrop.Dispose()

function Save-Icon([System.Drawing.Bitmap]$bitmap, [int]$size, [string]$outName, [bool]$rounded) {
    $dest = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::FromArgb(7, 10, 17)) # #070a11

    if ($rounded) {
        $radius = [int]($size * 0.18)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $radius * 2
        $rect = [System.Drawing.Rectangle]::new(0, 0, $size, $size)
        $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
        $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
        $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
        $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
        $path.CloseFigure()
        $g.SetClip($path)
    }

    $g.DrawImage($bitmap, [System.Drawing.Rectangle]::new(0, 0, $size, $size))
    $g.Dispose()

    $outPath = Join-Path $publicDir $outName
    $dest.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dest.Dispose()
    Write-Output "Saved $outPath ($size x $size)"
}

# Generate PWA Icons
Save-Icon $cropped 512 "icon-512.png" $false
Save-Icon $cropped 192 "icon-192.png" $false
Save-Icon $cropped 512 "icon-maskable-512.png" $false
Save-Icon $cropped 180 "apple-touch-icon.png" $false

# Generate favicon.ico (32x32 PNG inside ico or direct png)
Save-Icon $cropped 64 "favicon.png" $false

$cropped.Dispose()
$src.Dispose()
Write-Output "All icons generated successfully!"
