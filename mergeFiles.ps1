<#
.SYNOPSIS
    PowerShell 스크립트를 사용하여 쪼개진 파일들을 원래 파일로 돌리고 원본 파일 확장자까지 돌려냅니다.

.DESCRIPTION
    PowerShell 스크립트를 사용하여 쪼개진 파일들을 원래 파일로 돌리고 원본 파일 확장자까지 돌려냅니다.

.EXAMPLE
    PowerShell 실행
    -SourceFolder 옵션에 쪼개진 파일들이 모여있는 경로 입력
    -DestinationFolder 옵션에 쪼개진 파일들이 합쳐저 저장될 폴더를 입력
    .\mergeFiles.ps1 -SourceFolder "C:\Path\To\쪼개진파일들의모임폴더" -DestinationFolder "C:\Path\To\결과물저장폴더"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Splited_Files_SourceFolder,

    [Parameter(Mandatory = $true)]
    [string]$DestinationFolderForMergedFile
)

# Input 된 SourceFolder 및 DestinationFolder의 경로를 확인
if (-not (Test-Path $Splited_Files_SourceFolder)) {
    Write-Error "Source folder does not exist: $Splited_Files_SourceFolder"
    exit 1
}

if (-not (Test-Path $DestinationFolderForMergedFile)) {
    Write-Error "Destination folder does not exist: $DestinationFolderForMergedFile"
    exit 1
}

# 쪼개진 파일들의 list를 가져오기
# 쪼개진 파일들의 index를 파일이름으로 부터 정렬한다(정렬 기능이 없을때, 큰 파일을 merge하는 경우 문제였음(ex. 110,11,111) 순서로 합쳐 파일이 깨지는 현상)
$Files = Get-ChildItem -Path $Splited_Files_SourceFolder -Filter "*.jpg"| Sort-Object { [int]($_.BaseName -replace '^.*_([0-9]+).*$', '$1') }

# 원래 파일의 확장자를 쪼개진 0번째 파일로부터 가져온다. 
$FirstFileName = $Files[0].BaseName
$OriginalExtension = $FirstFileName.Substring($FirstFileName.LastIndexOf('_') + 1)

# 원래 파일의 이름을 가져온다. 
$OriginalBaseName = $FirstFileName.Substring(0, $FirstFileName.LastIndexOf('_'))
$DestinationFile = [System.IO.Path]::Combine($DestinationFolderForMergedFile, "$OriginalBaseName$OriginalExtension")

# Open output file stream.
try {
    $OutputStream = [System.IO.File]::OpenWrite($DestinationFile)
} catch {
    Write-Error "Unable to create output file: $DestinationFile"
    exit 1
}

# 쪼개진 파일 합치기
foreach ($File in $Files) {
    try {
        $InputStream = [System.IO.File]::OpenRead($File.FullName)
        $Buffer = New-Object byte[] $InputStream.Length
        $BytesRead = $InputStream.Read($Buffer, 0, $InputStream.Length)
        $OutputStream.Write($Buffer, 0, $BytesRead)
        $InputStream.Close()
        Write-Output "File merged: $($File.FullName)"
    } catch {
        Write-Error "Unable to read or write file: $($File.FullName)"
        exit 1
    }
}

$OutputStream.Close()
Write-Output "All file merge operations completed."
