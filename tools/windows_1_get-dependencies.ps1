#!/usr/bin/env pwsh

# Windows dependency bootstrap for CI.
# This script is intended to be run on GitHub Actions windows-latest runner.
# It will attempt to install lightweight requirements (NSIS) and will
# clone/build OpenSceneGraph, Simbody and OpenSim from source similar to
# the Linux/macOS helper scripts.

param()

Set-StrictMode -Version Latest

Write-Host "==> Windows dependency bootstrap (CI)"

function Install-ChocoPackage([string]$pkg) {
    Write-Host "Installing $pkg via Chocolatey..."
    choco install -y $pkg
}

try {
    # Ensure choco is available
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found - installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    Install-ChocoPackage -pkg 'nsis'
    Install-ChocoPackage -pkg '7zip'
    # git/cmake are expected on the GitHub runner, but install if missing
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Install-ChocoPackage -pkg 'git' }
    if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) { Install-ChocoPackage -pkg 'cmake' }
    # Optionally install Qt via choco if requested by env var
    if ($env:CI_INSTALL_QT -eq 'true') {
        Write-Host "Installing Qt via Chocolatey... (this may take a while)"
        choco install -y qt5
    }

    # Helper to clone a repo if it's not present
    function Try-Clone-Checkout([string]$url, [string]$ref) {
        $dir = [System.IO.Path]::GetFileNameWithoutExtension($url)
        if (-not (Test-Path $dir)) {
            Write-Host "Cloning $url ($ref)"
            git clone $url
            Push-Location $dir
            git checkout $ref
            Pop-Location
        } else {
            Write-Host "$dir already exists: skipping clone"
        }
    }

    # Clone OpenSceneGraph source if not present
    Try-Clone-Checkout "https://github.com/openscenegraph/OpenSceneGraph.git" "OpenSceneGraph-3.4.1"

    # Clone OpenSim source if not present
    Try-Clone-Checkout "https://github.com/tgeijten/opensim3-scone.git" "master"

    # Clone Simbody source if not present
    Try-Clone-Checkout "https://github.com/simbody/simbody.git" "Simbody-3.5.4"

    # Ensure submodules are initialized
    git submodule update --init --recursive

    Write-Host "Windows dependency bootstrap finished."
    exit 0
}
catch {
    Write-Host "Error while bootstrapping Windows dependencies: $_"
    exit 1
}
