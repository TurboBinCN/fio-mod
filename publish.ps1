param(
    [string]$modName = "PriyUtils"
)

# 检查参数合法性
if ([string]::IsNullOrEmpty($modName)) {
    Write-Host "错误：modName 参数不能为空" -ForegroundColor Red
    exit 1
}

# 检查文件夹是否存在
if (-not (Test-Path ".\$modName" -PathType Container)) {
    Write-Host "错误：文件夹 .\$modName 不存在" -ForegroundColor Red
    exit 1
}

taskkill /F /IM factorio.exe
Copy-Item ".\$modName" "C:\Users\Administrator\AppData\Roaming\Factorio\mods" -Recurse -Force
start steam://rungameid/427520