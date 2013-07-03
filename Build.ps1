param(
    [alias("env")]
    $Environment = 'debug',
    [alias("ftp")]
    $DeployToFtp = $true
)

function Build() {
    Try {
        if($Environment -ieq 'debug') {
            .\psake.ps1 ".\Deploy.ps1" -properties @{ config='debug'; environment="$Environment"}
        }
        if($Environment -ieq 'production') {
            .\psake.ps1 ".\Deploy.ps1" -properties @{ config='release'; environment="$Environment"; deployToFtp = $DeployToFtp } "production"
        }
        
        Write-Host "$Environment build done!"
    }
    Catch {
        throw "build failed"
        exit 1
    }
    Finally {
        if ($psake.build_success -eq $false) {
            exit 1
        }
        else {
            exit 0
        }
    }
}

Build