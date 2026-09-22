# Android SDK Command-line Tools 자동 설치 스크립트
# 관리자 권한 필수!

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android SDK Command-line Tools 설치" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 폴더 생성
Write-Host "`n[1/5] Android 폴더 생성 중..." -ForegroundColor Yellow
$androidPath = "C:\Android"
$cmdlineToolsPath = "$androidPath\cmdline-tools"

if (!(Test-Path $androidPath)) {
    New-Item -ItemType Directory -Path $androidPath -Force | Out-Null
    Write-Host "✅ $androidPath 폴더 생성됨" -ForegroundColor Green
} else {
    Write-Host "ℹ️  $androidPath 폴더 이미 존재" -ForegroundColor Cyan
}

# 2. Command-line tools 다운로드
Write-Host "`n[2/5] Command-line tools 다운로드 중..." -ForegroundColor Yellow
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zipPath = "$env:TEMP\commandlinetools-win.zip"
$extractPath = "$cmdlineToolsPath\temp"

try {
    Write-Host "다운로드 중... (약 500MB, 시간이 걸릴 수 있습니다)" -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -ErrorAction Stop
    Write-Host "✅ 다운로드 완료: $zipPath" -ForegroundColor Green
} catch {
    Write-Host "❌ 다운로드 실패: $_" -ForegroundColor Red
    Write-Host "수동 다운로드: https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Yellow
    Read-Host "엔터를 눌러 계속..."
    exit
}

# 3. 압축 해제
Write-Host "`n[3/5] 압축 해제 중..." -ForegroundColor Yellow
try {
    if (!(Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
    }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Write-Host "✅ 압축 해제 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ 압축 해제 실패: $_" -ForegroundColor Red
    exit
}

# 4. 폴더 구조 정리
Write-Host "`n[4/5] 폴더 구조 정리 중..." -ForegroundColor Yellow
try {
    # extracted 폴더 내 cmdline-tools를 latest로 이동
    $extractedCmdlineTools = "$extractPath\cmdline-tools"
    $latestPath = "$cmdlineToolsPath\latest"

    if (Test-Path $extractedCmdlineTools) {
        if (Test-Path $latestPath) {
            Remove-Item -Recurse -Force $latestPath
        }
        Move-Item -Path $extractedCmdlineTools -Destination $latestPath -Force
        Write-Host "✅ 폴더 정리 완료" -ForegroundColor Green
    }

    # 임시 폴더 삭제
    Remove-Item -Recurse -Force $extractPath -ErrorAction SilentlyContinue
    Remove-Item -Force $zipPath -ErrorAction SilentlyContinue
} catch {
    Write-Host "⚠️  폴더 정리 중 경고: $_" -ForegroundColor Yellow
}

# 5. 환경 변수 설정
Write-Host "`n[5/5] 환경 변수 설정 중..." -ForegroundColor Yellow
try {
    # ANDROID_HOME 설정
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidPath, "User")
    Write-Host "✅ ANDROID_HOME=$androidPath 설정됨" -ForegroundColor Green

    # PATH에 cmdline-tools\latest\bin 추가
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPathEntry = "$cmdlineToolsPath\latest\bin"

    if ($currentPath -notlike "*$newPathEntry*") {
        $newPath = "$currentPath;$newPathEntry"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "✅ PATH에 $newPathEntry 추가됨" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  PATH에 이미 등록됨" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ 환경 변수 설정 실패: $_" -ForegroundColor Red
    exit
}

# 설치 완료
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ 설치 완료!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n다음 단계:" -ForegroundColor Yellow
Write-Host "1. PowerShell을 완전히 닫았다가 다시 열기" -ForegroundColor White
Write-Host "2. 다음 명령어 실행:" -ForegroundColor White
Write-Host "   sdkmanager --list-installed" -ForegroundColor Cyan
Write-Host "`n설치 폴더: $androidPath" -ForegroundColor Cyan

Read-Host "`n엔터를 눌러 종료"
