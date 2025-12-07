#!/usr/bin/env pwsh

Set-StrictMode -Version Latest

Write-Host "Building SCONE Studio (Windows)"

$CMAKE_BUILD_TYPE = $env:CMAKE_BUILD_TYPE
if (-not $CMAKE_BUILD_TYPE) { $CMAKE_BUILD_TYPE = 'Release' }

$NUM_BUILD_JOBS = $env:NUM_BUILD_JOBS
if (-not $NUM_BUILD_JOBS) { $NUM_BUILD_JOBS = 2 }

if (-not $env:OSG_INSTALL_PATH) { $env:OSG_INSTALL_PATH = "${PWD}/OpenSceneGraph/install" }
if (-not $env:OPENSIM3_INSTALL_PATH) { $env:OPENSIM3_INSTALL_PATH = "${PWD}/opensim3-scone/install" }
if (-not $env:SCONE_BUILD_DIR) { $env:SCONE_BUILD_DIR = "${PWD}/build" }
if (-not $env:SCONE_INSTALL_DIR) { $env:SCONE_INSTALL_DIR = "${PWD}/install" }

Write-Host "OSG_INSTALL_PATH = $($env:OSG_INSTALL_PATH)"
Write-Host "OPENSIM3_INSTALL_PATH = $($env:OPENSIM3_INSTALL_PATH)"
Write-Host "SCONE_BUILD_DIR = $($env:SCONE_BUILD_DIR)"

if (-not (Test-Path $env:SCONE_BUILD_DIR)) { New-Item -ItemType Directory -Force -Path $env:SCONE_BUILD_DIR | Out-Null }
if (-not (Test-Path $env:SCONE_INSTALL_DIR)) { New-Item -ItemType Directory -Force -Path $env:SCONE_INSTALL_DIR | Out-Null }

Push-Location $env:SCONE_BUILD_DIR

cmake .. `
    -G "Visual Studio 17 2022" -A x64 `
    -DOSG_DIR="${env:OSG_INSTALL_PATH}" `
    -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" `
    -DCMAKE_VERBOSE_MAKEFILE="$env:CMAKE_VERBOSE_MAKEFILE" `
    -DCMAKE_INSTALL_PREFIX="${env:SCONE_INSTALL_DIR}" `
    -DOPENSIM_INSTALL_DIR="${env:OPENSIM3_INSTALL_PATH}" `
    -DOPENSIM_INCLUDE_DIR="${env:OPENSIM3_INSTALL_PATH}/sdk/include" `
    -DSCONE_OPENSIM_3=ON `
    -DSCONE_STUDIO_CPACK=ON `
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build . --parallel $NUM_BUILD_JOBS --config $CMAKE_BUILD_TYPE

Pop-Location
