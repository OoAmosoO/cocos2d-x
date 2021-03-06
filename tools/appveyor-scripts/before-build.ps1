$python = "C:\\Python27\\python.exe"

function Download-Deps
{
    Write-Host "Download-Deps"
    & $python $env:APPVEYOR_BUILD_FOLDER\download-deps.py --remove-download=False
}

function Download-NDK
{
	$url = "https://dl.google.com/android/repository/android-ndk-r16-windows-x86.zip"
    $output = "$env:APPVEYOR_BUILD_FOLDER/../android-ndk-r16-windows-x86.zip"
    Write-Host "downloading $url"
	Start-FileDownload $url $output
	Write-Host "finish downloading $url"

	Write-Host "installing NDK"
    Push-Location $env:APPVEYOR_BUILD_FOLDER/../
	$zipfile = $output
    Invoke-Expression "7z.exe x $zipfile"
	Write-Host "finish installing NDK"
    Pop-Location
    $env:NDK_ROOT = "$env:APPVEYOR_BUILD_FOLDER/../android-ndk-r16"
    Write-Host "set environment NDK_ROOT to $env:NDK_ROOT"
}

function Generate-Binding-Codes
{

    # install python module
    & pip install PyYAML Cheetah
	Write-Host "generating binding codes"

    $env:PYTHON_BIN = $python
	Write-Host "set environment viriable PYTHON_BIN to $env:PYTHON_BIN"

	Push-Location $env:APPVEYOR_BUILD_FOLDER\tools\tolua
	& $python $env:APPVEYOR_BUILD_FOLDER\tools\tolua\genbindings.py
	Pop-Location

    Push-Location $env:APPVEYOR_BUILD_FOLDER\tools\tojs
	& $python $env:APPVEYOR_BUILD_FOLDER\tools\tojs\genbindings.py
	Pop-Location
}

function Update-SubModule
{
	Push-Location $env:APPVEYOR_BUILD_FOLDER
	& git submodule init
	& git submodule update --recursive
	Pop-Location
}

Update-SubModule
Download-Deps
Download-NDK
Generate-Binding-Codes