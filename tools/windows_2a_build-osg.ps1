
#!/usr/bin/env pwsh

Set-StrictMode -Version Latest

Write-Host "Building OpenSceneGraph (Windows)"

$CMAKE_BUILD_TYPE = $env:CMAKE_BUILD_TYPE
if (-not $CMAKE_BUILD_TYPE) { $CMAKE_BUILD_TYPE = 'Release' }

$NUM_BUILD_JOBS = $env:NUM_BUILD_JOBS
if (-not $NUM_BUILD_JOBS) { $NUM_BUILD_JOBS = 2 }

if (-not $env:OSG_INSTALL_PATH) {
    Write-Host "OSG_INSTALL_PATH not set, using default: C:\OpenSceneGraph-install"
    $env:OSG_INSTALL_PATH = "C:\OpenSceneGraph-install"
}

Write-Host "OSG_INSTALL_PATH = $($env:OSG_INSTALL_PATH)"

Write-Host "mkdir -p $env:OSG_INSTALL_PATH"
New-Item -ItemType Directory -Force -Path $env:OSG_INSTALL_PATH | Out-Null

if (-not (Test-Path "OpenSceneGraph/build")) { New-Item -ItemType Directory -Force -Path "OpenSceneGraph/build" | Out-Null }

Push-Location "OpenSceneGraph/build"

cmake .. `
    -G "Visual Studio 17 2022" -A x64 `
      -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" `
      -DCMAKE_VERBOSE_MAKEFILE="$env:CMAKE_VERBOSE_MAKEFILE" `
      -DUSE_RPATH=OFF `
      -DCMAKE_INSTALL_PREFIX="$env:OSG_INSTALL_PATH" `
      -DOSG_USE_QT=ON `
      -DDESIRED_QT_VERSION=5

cmake --build . --parallel $NUM_BUILD_JOBS --config $CMAKE_BUILD_TYPE --target INSTALL

Pop-Location
