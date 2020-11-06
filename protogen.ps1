#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

# Generate image and container names using the data in the "component.json" file
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Get buildnumber from github actions
if ($env:GITHUB_RUN_NUMBER -ne $null) {
    $component.build = $env:GITHUB_RUN_NUMBER
    Set-Content -Path "component.json" -Value $($component | ConvertTo-Json)
}

$protoImage="$($component.registry)/$($component.name):$($component.version)-$($component.build)-protos"
$container=$component.name

# Remove build files
if (Test-Path "./protos") {
    Remove-Item -Recurse -Force -Path "./protos/*.go"
} else {
    New-Item -ItemType Directory -Force -Path "./protos"
}

# Copy private keys to access git repo
if (-not (Test-Path -Path "docker/id_rsa")) {
    if ($env:GIT_PRIVATE_KEY -ne $null) {
        Set-Content -Path "docker/id_rsa" -Value $env:GIT_PRIVATE_KEY
    } else {
        Copy-Item -Path "~/.ssh/id_rsa" -Destination "docker"
    }
}

# Build docker image
docker build -f docker/Dockerfile.protogen -t $protoImage .

# Create and copy compiled files, then destroy the container
docker create --name $container $protoImage
docker cp "$($container):/go/nov/protos" ./
docker rm $container

# Verify that protos folder created after generating proto files
if (!(Test-Path "./protos")) {
    Write-Host "protos folder doesn't exist in root dir. Build failed. Watch logs above."
    exit 1
}
