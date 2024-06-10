<#
.SYNOPSIS
    큰 파일을 전송하기 위해 파일을 원하는 KB단위로 자를수 있는 PowerShell 스크립트이며, 원본 확장자와 파일이름명을 보존합니다.

.DESCRIPTION
    큰 파일을 전송하기 위해 파일을 원하는 KB단위로 자를수 있는 PowerShell 스크립트이며, 원본 확장자와 파일이름명을 보존합니다.
    쪼개진 파일들은 ".jpg"확장자로 저장됩니다.
.EXAMPLE
    Powershell 실행
    -SourceFile 옵션에 해당 파일 경로와 확장자까지 입력
    -DestinationFolder 옵션에 나눠질 파일들이 저장될 경로를 저장
    -TargetSizeKB에 KB단위로 입력 (휴대폰과 연결 App의 사진전송은 1MB(1024KB)이하 입니다.)
    .\splitFile.ps1 -SourceFile "C:\Path\To\LargeFile.pdf" -DestinationFolder "C:\Path\To\저장할폴더" -TargetSizeKB 1024
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SourceFile,

    [Parameter(Mandatory = $true)]
    [string]$DestinationFolder,

    [Parameter(Mandatory = $true)]
    [double]$TargetSizeKB
)

# Input 된 sourceFile 및 DestinationFolder의 경로를 확인
if (-not (Test-Path $SourceFile)) {
    Write-Error "Source file does not exist: $SourceFile"
    exit 1
}

if (-not (Test-Path $DestinationFolder)) {
    Write-Error "Destination folder does not exist: $DestinationFolder"
    exit 1
}

# KilloByte를 byte로 변환
$TargetSizeBytes = $TargetSizeKB * 1024

# 원본파일의 확장자를 가져온다.
$OriginalExtension = [System.IO.Path]::GetExtension($SourceFile)

# Open file stream.
try {
    $InputStream = [System.IO.File]::OpenRead($SourceFile)
} catch {
    Write-Error "Unable to open file: $SourceFile"
    exit 1
}

# 버퍼를 생성
$Buffer = New-Object byte[] $TargetSizeBytes
$Index = 0

# 파일 쪼개기
while ($InputStream.Position -lt $InputStream.Length) {
    $BytesRead = $InputStream.Read($Buffer, 0, $TargetSizeBytes)
    $ChunkFileName = [System.IO.Path]::Combine($DestinationFolder, "$([System.IO.Path]::GetFileNameWithoutExtension($SourceFile))_$($Index)$OriginalExtension.jpg")

    try {
        $ChunkStream = [System.IO.File]::OpenWrite($ChunkFileName)
        $ChunkStream.Write($Buffer, 0, $BytesRead)
        $ChunkStream.Close()
        Write-Output "Split file created: $ChunkFileName"
    } catch {
        Write-Error "Unable to save file: $ChunkFileName"
        exit 1
    }

    $Index++
}

$InputStream.Close()
Write-Output "All file splitting operations completed."
