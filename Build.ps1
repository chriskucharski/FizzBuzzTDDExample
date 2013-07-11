param(
    [alias("env")]
    $Environment = 'debug',
    [alias("ftp")]
    $DeployToFtp = $true
)

function Build() {
    Try {
        if($Environment -ieq 'debug') {
            .\psake.ps1 ".\default.ps1" -properties @{ config='debug'; environment="$Environment"}
        }
        if($Environment -ieq 'production') {
            .\psake.ps1 ".\default.ps1" -properties @{ config='release'; environment="$Environment"; deployToFtp = $DeployToFtp } "production"
        }
    }
    Catch {
        throw "$Environment build failed!"
        exit 1
    }
    Finally {
        if ($psake.build_success -eq $false) {
            Write-Host "$Environment build failed!"
			exit 1
        }
        else {
			Write-Host "$Environment build succeeded!"
            exit 0
        }
    }
}

Build