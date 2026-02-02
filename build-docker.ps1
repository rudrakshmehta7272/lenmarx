#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Build Lenmarx blockchain binary using Docker
    
.DESCRIPTION
    Automatically builds lenmarxd binary in Docker container
    and extracts it to cmd/lenmarxd/lenmarxd
    
.EXAMPLE
    .\build-docker.ps1
    
.NOTES
    Requires: Docker Desktop installed and running
#>

param(
    [string]$ImageTag = "lenmarx:latest",
    [switch]$KeepImage = $false
)

function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "▶ $Message" -ForegroundColor $Color
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
    exit 1
}

# Check Docker
Write-Status "Checking Docker..."
try {
    $dockerVersion = docker --version
    Write-Status "Found: $dockerVersion"
} catch {
    Write-Error-Custom "Docker not found or not running. Install Docker Desktop and ensure it's running."
}

# Get current directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path "$scriptDir/Dockerfile")) {
    Write-Error-Custom "Dockerfile not found in $scriptDir"
}

Write-Status "Building Docker image: $ImageTag" "Cyan"
docker build -t $ImageTag "$scriptDir"
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Docker build failed"
}

Write-Status "Docker image built successfully" "Green"

# Create container to extract binary
Write-Status "Extracting binary from image..." "Cyan"
$containerId = docker create $ImageTag
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Failed to create Docker container"
}

# Ensure output directory exists
$outputDir = "$scriptDir/cmd/lenmarxd"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Status "Created directory: $outputDir"
}

# Copy binary from container
docker cp "${containerId}:/usr/local/bin/lenmarxd" "$outputDir/lenmarxd"
if ($LASTEXITCODE -ne 0) {
    docker rm $containerId | Out-Null
    Write-Error-Custom "Failed to extract binary from container"
}

# Cleanup
docker rm $containerId | Out-Null
if (-not $KeepImage) {
    docker image rm $ImageTag | Out-Null
    Write-Status "Cleaned up Docker image"
}

# Verify binary
Write-Status "Verifying binary..." "Cyan"
if (-not (Test-Path "$outputDir/lenmarxd")) {
    Write-Error-Custom "Binary not found at $outputDir/lenmarxd"
}

$fileInfo = Get-Item "$outputDir/lenmarxd"
Write-Status "Binary created successfully"
Write-Status "Location: $($fileInfo.FullName)" "Green"
Write-Status "Size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" "Green"

# Display next steps
Write-Host ""
Write-Host "✓ Build successful! Next steps:" -ForegroundColor Green
Write-Host ""
Write-Host "  On Linux/WSL2, test the binary:"
Write-Host "  $ ./cmd/lenmarxd/lenmarxd --version"
Write-Host "  $ ./cmd/lenmarxd/lenmarxd --help"
Write-Host ""
Write-Host "  The binary is a Linux ELF executable and runs on:"
Write-Host "  - Linux (native)"
Write-Host "  - WSL2"
Write-Host "  - Docker containers"
Write-Host ""
