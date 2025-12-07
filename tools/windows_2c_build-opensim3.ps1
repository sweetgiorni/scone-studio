
#!/usr/bin/env pwsh

Set-StrictMode -Version Latest

Write-Host "Building OpenSim (Windows)"

$CMAKE_BUILD_TYPE = $env:CMAKE_BUILD_TYPE
if (-not $CMAKE_BUILD_TYPE) { $CMAKE_BUILD_TYPE = 'Release' }

$NUM_BUILD_JOBS = $env:NUM_BUILD_JOBS
if (-not $NUM_BUILD_JOBS) { $NUM_BUILD_JOBS = 2 }

if (-not $env:OPENSIM3_INSTALL_PATH) {
    Write-Host "OPENSIM3_INSTALL_PATH not set, using default: C:\opensim3-install"
    $env:OPENSIM3_INSTALL_PATH = "C:\opensim3-install"
}

if (-not $env:SIMBODY_INSTALL_PATH) {
    Write-Host "SIMBODY_INSTALL_PATH not set, using default: C:\simbody-install"
    $env:SIMBODY_INSTALL_PATH = "C:\simbody-install"
}

Write-Host "OPENSIM3_INSTALL_PATH = $($env:OPENSIM3_INSTALL_PATH)"
Write-Host "SIMBODY_INSTALL_PATH = $($env:SIMBODY_INSTALL_PATH)"

New-Item -ItemType Directory -Force -Path $env:OPENSIM3_INSTALL_PATH | Out-Null

if (-not (Test-Path "opensim3-scone/build")) { New-Item -ItemType Directory -Force -Path "opensim3-scone/build" | Out-Null }

Push-Location "opensim3-scone/build"

cmake .. `
    -G "Visual Studio 17 2022" -A x64 `
      -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" `
      -DCMAKE_VERBOSE_MAKEFILE="$env:CMAKE_VERBOSE_MAKEFILE" `
      -DSIMBODY_HOME="$env:SIMBODY_INSTALL_PATH" `
      -DCMAKE_INSTALL_PREFIX="$env:OPENSIM3_INSTALL_PATH" `
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build . --parallel $NUM_BUILD_JOBS --config $CMAKE_BUILD_TYPE --target INSTALL

Pop-Location
