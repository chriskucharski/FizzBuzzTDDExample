# properties that is used by the script
properties {
    $dateLabel = ([DateTime]::Now.ToString("yyyy-MM-dd_HH-mm-ss"))
    $baseDir = "C:\Users\x1vs\Documents\Visual Studio 2012\Projects\FizzBuzzTDDExample\"
    $sourceDir = "$baseDir\FizzBuzzTDDExample\"
    $toolsDir = "$sourceDir\"
    $deployBaseDir = "$baseDir\Deploy\"
    $deployPkgDir = "$deployBaseDir\Package\"
    $backupDir = "$deployBaseDir\Backup\"
    $testBaseDir = "$baseDir\FizzBuzzTDDExampleTests\"
    $config = 'debug'
    $environment = 'debug'
}

# the default task that is executed if no task is defined when calling this script
task default -depends local
# task that is used when building the project at a local development environment, depending on the mergeConfig task
task local -depends mergeConfig
# task that is used when building for production, depending on the deploy task
task production -depends deploy

# task that is setting up needed stuff for the build process
task setup {
    # removing and creating folders needed for the build, deploy package dir and a backup dir with a date
    Remove-ThenAddFolder $deployPkgDir
    Remove-ThenAddFolder $backupDir
    Remove-ThenAddFolder "$backupDir\$dateLabel"
}

# compiling csharp and client script with bundler
task compile -depends setup {
    # executing msbuild for compiling the project
    exec { msbuild  $sourceDir\FizzBuzzTDDExample.sln /t:Clean /t:Build /p:Configuration=$config /v:q /nologo
}

<#
    executing Bundle.ps1, Bundle.ps1 is a wrapper around bundler that is compiling client script the wrapper also is executed as
	post-build script when compiling in debug mode.
	For more info check out => http://antonkallenberg.com/2012/07/26/using-servicestack-bundler/
#>
<#
.\Bundle.ps1
# checking so that last exit code is ok else break the build
if($LASTEXITCODE -ne 0) {
    throw "Failed to bundle client scripts"
    exit 1
    }
}
#>

# running unit tests
task test -depends compile {
    # executing mspec and suppling the test assembly
    &"$sourceDir\packages\NUnit.2.6.2\lib\nunit.framework.dll" "$testBaseDir\bin\$config\FizzBuzzTDDExampleTests.dll"
    # checking so that last exit code is ok else break the build
    if($LASTEXITCODE -ne 0) {
        throw "Failed to run unit tests"
        exit 1
    }
}

#helper methods
function Remove-IfExists([string]$name) {
    if ((Test-Path -path $name)) {
        dir $name -recurse | where {!@(dir -force $_.fullname)} | rm
        Remove-Item $name -Recurse
    }
}

function Remove-ThenAddFolder([string]$name) {
    Remove-IfExists $name
    New-Item -Path $name -ItemType "directory"
}

function Remove-LastChar([string]$str) {
    $str.Remove(($str.Length-1),1)
}