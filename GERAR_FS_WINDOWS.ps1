$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

$ToolsRoot = Join-Path $ProjectRoot ".tools\mklittlefs"
$ArchivePath = Join-Path $ToolsRoot "mklittlefs-windows.zip"
$ExtractPath = Join-Path $ToolsRoot "bin"
$DownloadUrl = "https://github.com/earlephilhower/mklittlefs/releases/download/4.1.0/x86_64-w64-mingw32-mklittlefs-42acb97.zip"
$ExpectedSha256 = "B57F64DF7303651DF2127B3032C33431DBF6A8C2E8949945AD588A2B6C6EE394"

New-Item -ItemType Directory -Force -Path $ToolsRoot | Out-Null

$Mklittlefs = Get-ChildItem -Path $ExtractPath -Filter "mklittlefs.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $Mklittlefs) {
    Write-Host "Baixando mklittlefs oficial..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchivePath

    $ActualSha256 = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash
    if ($ActualSha256 -ne $ExpectedSha256) {
        throw "O arquivo baixado falhou na verificacao SHA-256."
    }

    if (Test-Path $ExtractPath) {
        Remove-Item $ExtractPath -Recurse -Force
    }

    Expand-Archive -Path $ArchivePath -DestinationPath $ExtractPath -Force
    $Mklittlefs = Get-ChildItem -Path $ExtractPath -Filter "mklittlefs.exe" -Recurse | Select-Object -First 1
}

if (-not $Mklittlefs) {
    throw "Nao foi possivel localizar mklittlefs.exe."
}

$SourceFolder = Join-Path $ProjectRoot "src"
$OutputFile = Join-Path $ProjectRoot "fs.bin"

Write-Host "Gerando fs.bin com o src/main.py..."
& $Mklittlefs.FullName -c $SourceFolder -b 4096 -p 256 -s 0x200000 $OutputFile

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $OutputFile)) {
    throw "Falha ao gerar fs.bin."
}

Write-Host "fs.bin gerado com sucesso: $OutputFile" -ForegroundColor Green
Write-Host "Agora abra diagram.json e clique no botao verde do Wokwi."
