# properties that is used by the script
properties {
	$config = 'debug'
    $environment = 'debug'
    $dateLabel = ([DateTime]::Now.ToString("yyyy-MM-dd_HH-mm-ss"))
    $baseDir = resolve-path .\
    $sourceDir = "$baseDir\FizzBuzzTDDExample\"
	$testBaseDir = "$baseDir\FizzBuzzTests\"
	$nUnitPath = "C:\Program Files (x86)\NUnit 2.6.2\bin\nunit-console.exe"
    $deployBaseDir = "$baseDir\Deploy"
    $deployPkgDir = "$deployBaseDir\Package\"
    $backupDir = "$deployBaseDir\Backup"
    $toolsDir = "$sourceDir\"
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
	$msBuild = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
	$build = $msBuild + " ""$baseDir\FizzBuzzTDDExample.sln"" " + " /t:Clean" + " /t:Build" + " /p:Configuration=$config" + " /nologo"
	Invoke-Expression $build
	
	# checking to ensure the compile process succeeded, else break the build
	if($LASTEXITCODE -gt 0) {
		throw "MSBuild compile failed"
		exit 1
	}
}

# running unit tests
task test -depends compile {
    # executing nunit and supplying the test assembly
    &"$nUnitPath" "$testBaseDir\bin\$config\FizzBuzzTests.dll"
    # checking so that last exit code is ok else break the build
    if($LASTEXITCODE -ne 0) {
        throw "NUnit tests failed!"
        exit 1
    }
}

# copying the deployment package
task copyPkg -depends test {
	# robocopy has some issue with a trailing slash in the path (or it's by design, don't know), lets remove that slash
	$deployPath = Remove-LastChar "$deployPkgDir"
	# copying the required files for the deloy package to the deploy folder created at setup
	
	$tempSourcePath = $sourceDir.Substring(3)
	$tempDeployPath = $deployPath.Substring(3)
	robocopy /"$tempSourcePath/" /"$tempDeployPath/" /MIR /XD obj bundler Configurations Properties /XF *.bundle *.coffee *.less *.pdb *.cs *.csproj *.csproj.user *.sln .gitignore README.txt packages.config
	
	# checking so that last exit code is ok else break the build (robocopy returning greater that 1 if fail)
	if($LASTEXITCODE -gt 1) {
		throw "robocopy command failed"
		exit 1
	}
}

# merging and doing config transformations
task mergeConfig -depends copyPkg {

}

# deploying the package
task deploy -depends mergeConfig {
	# only if production and deployToFtp property is set to true
	if($environment -ieq "production" -and $deployToFtp -eq $true) {
		# Setting the connection to the production ftp
		Set-FtpConnection $ftpProductionHost $ftpProductionUsername $ftpProductionPassword
		# backing up before deploy => by downloading and uploading the current webapplication at production enviorment
		$localBackupDir = Remove-LastChar "$backupDir"
		Get-FromFtp "$backupDir\$dateLabel" "$ftpProductionWebRootFolder"
		Send-ToFtp "$localBackupDir" "$ftpProductionBackupFolder"
		
		# redeploying the application => by removing the existing application and upload the new one
		Remove-FromFtp "$ftpProductionWebRootFolder"
		$localDeployPkgDir = Remove-LastChar "$deployPkgDir"
		Send-ToFtp "$localDeployPkgDir" "$ftpProductionWebRootFolder"
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