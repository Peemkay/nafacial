Add-Type -AssemblyName System.Drawing
$inputFile = "assets\favicon\web\favicon.png"
$outputFile = "windows\runner\resources\app_icon.ico"

# Create a bitmap from the input file
$bitmap = [System.Drawing.Image]::FromFile((Resolve-Path $inputFile))

# Save as ICO
$memoryStream = New-Object System.IO.MemoryStream
$bitmap.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Icon)
$bytes = $memoryStream.ToArray()
[System.IO.File]::WriteAllBytes((Resolve-Path -Path ".\" -Relative) + "\" + $outputFile, $bytes)

Write-Host "Converted $inputFile to $outputFile"
