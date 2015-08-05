# Author:  Lisandro Dalcin
# Contact: dalcinl@gmail.com

$ANACONDA_BASE_URL = "http://repo.continuum.io/miniconda/"
$ANACONDA_VERSION = "3.10.1"

$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
. "$ScriptDir\download.ps1"
$DOWNLOADS = "C:\Downloads\Anaconda"

function InstallAnaconda ($python_version, $architecture, $anaconda_home) {
    $python_version = $python_version.SubString(0,1)
    Write-Host "Installing Anaconda $ANACONDA_VERSION (Python $python_version, $architecture-bit) to $anaconda_home"
    if (Test-Path $anaconda_home) {
        Write-Host $anaconda_home "already exists, skipping."
        return
    }
    $pver = @{"2"="";"3"="3"}[$python_version]
    $arch = @{"32"="x86";"64"="x86_64"}[$architecture]
    $filename = "Miniconda" + $pver + "-" + $ANACONDA_VERSION + "-Windows-" + $arch + ".exe"
    $url = $ANACONDA_BASE_URL + $filename
    $filepath = Download $url $filename $DOWNLOADS
    Write-Host "Installing" $filename "to" $anaconda_home
    $args = "/S /D=$anaconda_home"
    Write-Host $filepath $args
    Start-Process -FilePath $filepath -ArgumentList $args -Wait
    Write-Host "Installing additional Anaconda packages"
    $prog = Join-Path $anaconda_home "Scripts\conda.exe"
    $args = "install --quiet --yes binstar conda-build jinja2"
    Write-Host $prog $args
    Start-Process -FilePath $prog -ArgumentList $args -Wait
    Write-Host "Anaconda installation complete"
}

function UpdateAnaconda ($anaconda_home) {
    Write-Host "Updating Anaconda"
    $conda = Join-Path $anaconda_home "Scripts\conda.exe"
    $commands = @(
        "update --yes --quiet --all",
        "update --yes --quiet binstar conda-build jinja2",
        "clean  --yes --lock --tarballs"
    )
    foreach($args in $commands) {
        Write-Host $conda $args
        Start-Process -FilePath $conda -ArgumentList $args -Wait
    }
}

function main () {
    InstallAnaconda $env:PYTHON_VERSION $env:PYTHON_ARCH $env:ANACONDA
    UpdateAnaconda  $env:ANACONDA
}

main
