@echo off
rem ============================================================================
rem  Epic Flail - installer / updater.  Double-click it, type the folder, wait.
rem  Downloads the newest game build from GitHub, unpacks it, makes a desktop shortcut.
rem  Run it again later to update to the newest version (same folder).
rem  Advanced: Install_EpicFlail.bat "D:\Games\Epic Flail" /auto   (no questions)
rem ============================================================================
setlocal
set "EF_SELF=%~f0"
set "EF_ARG1=%~1"
set "EF_ARG2=%~2"
title Epic Flail
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:EF_SELF,[Text.Encoding]::UTF8); $i=$s.IndexOf('#'+'==POWERSHELL=='); & ([ScriptBlock]::Create($s.Substring($i)))"
set "EF_CODE=%ERRORLEVEL%"
if not "%EF_CODE%"=="0" if /i not "%EF_ARG2%"=="/auto" pause
exit /b %EF_CODE%

#==POWERSHELL==
# ------------------------------------------------------------------------------------------------------------------
# Всё, что ниже, выполняет PowerShell (есть в любой Windows 10/11). Только стандартные средства Windows.
# ------------------------------------------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
$Repo      = 'Archiefx/EpicFlail-Releases'      # откуда брать сборки (публичный репозиторий)
$GameName  = 'Epic Flail'
$ExeName   = 'EpicFlail.exe'
$DefaultDir = Join-Path $env:SystemDrive 'Games\Epic Flail'
$Auto      = ($env:EF_ARG2 -eq '/auto')

# ---------- язык сообщений: по языку Windows (русский / польский / английский) ----------
$lang = (Get-Culture).TwoLetterISOLanguageName
if ($lang -in @('ru','be','uk','kk')) { $lang = 'ru' } elseif ($lang -ne 'pl') { $lang = 'en' }
$T = @{
 ru = @{
  title='Установка игры Epic Flail'; ask='В какую папку установить игру?'; enter='Нажми Enter, чтобы согласиться с'
  folder='Папка'; check='Ищу самую свежую версию на GitHub...'; latest='Последняя версия'; size='размер'
  have='Эта версия уже установлена - скачивать нечего.'; dl='Скачиваю'; resume='Продолжаю с места обрыва'
  retry='Связь прервалась, пробую снова через {0} с (попытка {1})'; verify='Проверяю, что архив скачан без ошибок...'
  bad='Архив повреждён (контрольная сумма не совпала). Скачиваю заново.'; unpack='Распаковываю'
  running='Игра сейчас запущена. Закрой её и нажми Enter.'; prereq='Ставлю системные библиотеки Microsoft (Visual C++). Если Windows спросит разрешение - нажми "Да".'
  shortcut='Ярлык на рабочем столе'; done='Готово! Игра установлена в'; run='Запустить игру сейчас? (Y - да, Enter - нет)'
  fail='ОШИБКА'; nospace='Мало места на диске: нужно {0} ГБ, свободно {1} ГБ.'; nowrite='В эту папку нельзя записать. Выбери другую (например, на диске D:).'
  notempty='В этой папке уже лежат чужие файлы. Укажи пустую или новую папку.'
  oldwin='Нужна Windows 10 или 11 (64-бит).'; net='Не удалось связаться с GitHub. Проверь интернет и запусти установщик ещё раз - скачивание продолжится с места обрыва.'
  pressexit='Нажми Enter, чтобы закрыть окно.'; speed='МБ/с'; left='осталось'; mb='МБ'
 }
 pl = @{
  title='Instalacja gry Epic Flail'; ask='Do jakiego folderu zainstalować grę?'; enter='Naciśnij Enter, aby zgodzić się na'
  folder='Folder'; check='Szukam najnowszej wersji na GitHubie...'; latest='Najnowsza wersja'; size='rozmiar'
  have='Ta wersja jest już zainstalowana - nie ma czego pobierać.'; dl='Pobieram'; resume='Wznawiam od miejsca przerwania'
  retry='Połączenie przerwane, ponawiam za {0} s (próba {1})'; verify='Sprawdzam, czy archiwum pobrało się bez błędów...'
  bad='Archiwum jest uszkodzone (suma kontrolna się nie zgadza). Pobieram ponownie.'; unpack='Rozpakowuję'
  running='Gra jest teraz uruchomiona. Zamknij ją i naciśnij Enter.'; prereq='Instaluję biblioteki systemowe Microsoft (Visual C++). Jeśli Windows zapyta o zgodę - kliknij "Tak".'
  shortcut='Skrót na pulpicie'; done='Gotowe! Gra jest zainstalowana w'; run='Uruchomić grę teraz? (Y - tak, Enter - nie)'
  fail='BŁĄD'; nospace='Za mało miejsca na dysku: potrzeba {0} GB, wolne {1} GB.'; nowrite='Do tego folderu nie można zapisywać. Wybierz inny (np. na dysku D:).'
  notempty='W tym folderze są już inne pliki. Wskaż pusty lub nowy folder.'
  oldwin='Wymagany jest Windows 10 lub 11 (64-bit).'; net='Nie udało się połączyć z GitHubem. Sprawdź internet i uruchom instalator ponownie - pobieranie będzie kontynuowane.'
  pressexit='Naciśnij Enter, aby zamknąć okno.'; speed='MB/s'; left='zostało'; mb='MB'
 }
 en = @{
  title='Epic Flail setup'; ask='Which folder should the game be installed to?'; enter='Press Enter to accept'
  folder='Folder'; check='Looking for the newest version on GitHub...'; latest='Newest version'; size='size'
  have='This version is already installed - nothing to download.'; dl='Downloading'; resume='Resuming where it stopped'
  retry='Connection lost, retrying in {0} s (attempt {1})'; verify='Checking that the archive downloaded correctly...'
  bad='The archive is damaged (checksum mismatch). Downloading again.'; unpack='Unpacking'
  running='The game is running now. Close it and press Enter.'; prereq='Installing Microsoft system libraries (Visual C++). If Windows asks for permission, click "Yes".'
  shortcut='Desktop shortcut'; done='Done! The game is installed in'; run='Start the game now? (Y - yes, Enter - no)'
  fail='ERROR'; nospace='Not enough disk space: {0} GB needed, {1} GB free.'; nowrite='Cannot write to this folder. Choose another one (for example on drive D:).'
  notempty='This folder already contains other files. Choose an empty or new folder.'
  oldwin='Windows 10 or 11 (64-bit) is required.'; net='Could not reach GitHub. Check the internet and run the installer again - the download will continue where it stopped.'
  pressexit='Press Enter to close this window.'; speed='MB/s'; left='left'; mb='MB'
 }
}[$lang]

function Say([string]$text, [string]$color = 'Gray') { Write-Host $text -ForegroundColor $color }
function Stage([string]$text) { Write-Host ''; Write-Host ('>> ' + $text) -ForegroundColor Cyan }
function Finish([int]$code) { if (-not $Auto) { Write-Host ''; Read-Host $T.pressexit | Out-Null }; exit $code }

try {
    $Host.UI.RawUI.WindowTitle = $T.title
    Write-Host ''
    Write-Host ('  ' + $T.title) -ForegroundColor Yellow
    Write-Host ('  ' + ('=' * $T.title.Length)) -ForegroundColor Yellow

    if ([Environment]::OSVersion.Version.Major -lt 10 -or -not [Environment]::Is64BitOperatingSystem) { throw $T.oldwin }
    # GitHub принимает только современное шифрование
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]'Tls13' }
    catch { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 }

    # ---------- 1. куда ставить ----------
    $dir = $env:EF_ARG1
    if (-not $dir) {
        Write-Host ''
        Say $T.ask 'White'
        Say ('  ' + $T.enter + ': ' + $DefaultDir) 'DarkGray'
        $dir = Read-Host ('  ' + $T.folder)
        if (-not $dir) { $dir = $DefaultDir }
    }
    $dir = $dir.Trim().Trim('"').Trim()
    $dir = [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($dir))
    # Безопасность: при обновлении старое содержимое папки удаляется. Поэтому в чужую НЕпустую папку
    # (например, D:\Games или рабочий стол) игру ставим в подпапку "Epic Flail", а не прямо туда
    for ($k = 0; $k -lt 2; $k++) {
        $isOurs = Test-Path (Join-Path $dir 'installed_version.txt')
        $isEmpty = -not (Test-Path $dir) -or -not (Get-ChildItem -LiteralPath $dir -Force | Where-Object { $_.Name -notin @('_download', '_unpack') } | Select-Object -First 1)
        if ($isOurs -or $isEmpty) { break }
        if ($k -eq 1) { throw $T.notempty + "  ($dir)" }
        $dir = Join-Path $dir $GameName
    }
    try {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $probe = Join-Path $dir '.write_test'
        [IO.File]::WriteAllText($probe, 'ok'); Remove-Item $probe -Force
    } catch { throw $T.nowrite + "  ($dir)" }
    Say ('  ' + $T.folder + ': ' + $dir) 'White'

    # ---------- 2. какая версия свежая ----------
    Stage $T.check
    $headers = @{ 'User-Agent' = 'EpicFlail-Installer'; 'Accept' = 'application/vnd.github+json' }
    try { $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $headers -TimeoutSec 60 }
    catch { throw $T.net + "`n  " + $_.Exception.Message }
    $asset = $rel.assets | Where-Object { $_.name -like '*-Win64.zip' } | Select-Object -First 1
    if (-not $asset) { throw "No *-Win64.zip in release $($rel.tag_name)" }
    $tag = $rel.tag_name
    $size = [int64]$asset.size
    Say ('  ' + $T.latest + ': ' + $tag + '   (' + $T.size + ' ' + [math]::Round($size / 1MB) + ' ' + $T.mb + ')') 'White'
    # контрольная сумма: поле digest в ответе GitHub или файл .sha256 рядом с архивом
    $sha = $null
    if ($asset.PSObject.Properties.Name -contains 'digest' -and $asset.digest -like 'sha256:*') { $sha = $asset.digest.Substring(7).ToLower() }
    if (-not $sha) {
        $shaAsset = $rel.assets | Where-Object { $_.name -eq ($asset.name + '.sha256') } | Select-Object -First 1
        if ($shaAsset) {
            $c = (Invoke-WebRequest -Uri $shaAsset.browser_download_url -Headers @{ 'User-Agent' = 'EpicFlail-Installer' } -UseBasicParsing -TimeoutSec 60).Content
            if ($c -is [byte[]]) { $c = [Text.Encoding]::ASCII.GetString($c) }
            $sha = ($c.Trim() -split '\s+')[0].ToLower()
        }
    }

    $verFile = Join-Path $dir 'installed_version.txt'
    $exe = Join-Path $dir $ExeName
    $already = (Test-Path $verFile) -and (Test-Path $exe) -and ((Get-Content $verFile -Raw).Trim() -eq $tag)
    if ($already) {
        Say ('  ' + $T.have) 'Green'
    } else {
        # место: архив + распакованная игра (примерно вдвое больше архива) + запас
        $need = $size * 3.2
        $drive = New-Object IO.DriveInfo([IO.Path]::GetPathRoot($dir))
        if ($drive.AvailableFreeSpace -lt $need) { throw ($T.nospace -f [math]::Round($need / 1GB, 1), [math]::Round($drive.AvailableFreeSpace / 1GB, 1)) }

        # ---------- 3. скачивание с докачкой и индикатором ----------
        $dlDir = Join-Path $dir '_download'
        New-Item -ItemType Directory -Force -Path $dlDir | Out-Null
        $zip = Join-Path $dlDir $asset.name
        $part = $zip + '.part'
        Get-ChildItem $dlDir -File | Where-Object { $_.FullName -ne $zip -and $_.FullName -ne $part } | Remove-Item -Force -ErrorAction SilentlyContinue

        for ($round = 1; $round -le 2; $round++) {
            if (-not ((Test-Path $zip) -and (Get-Item $zip).Length -eq $size)) {
                Stage ($T.dl + ' ' + $asset.name)
                $attempt = 0; $failsNoProgress = 0
                while ($true) {
                    $have = 0; if (Test-Path $part) { $have = (Get-Item $part).Length }
                    if ($have -ge $size) { break }
                    $attempt++
                    try {
                        # GitHub отдаёт файл через перенаправление на CDN: берём настоящий адрес и качаем с него
                        $r0 = [Net.HttpWebRequest]::Create($asset.browser_download_url)
                        $r0.AllowAutoRedirect = $false; $r0.UserAgent = 'EpicFlail-Installer'; $r0.Timeout = 60000
                        $resp0 = $r0.GetResponse(); $url = $resp0.Headers['Location']; $resp0.Close()
                        if (-not $url) { $url = $asset.browser_download_url }
                        $req = [Net.HttpWebRequest]::Create($url)
                        $req.UserAgent = 'EpicFlail-Installer'; $req.Timeout = 60000; $req.ReadWriteTimeout = 60000
                        if ($have -gt 0) { $req.AddRange([int64]$have); Say ('  ' + $T.resume + ': ' + [math]::Round($have / 1MB) + ' / ' + [math]::Round($size / 1MB) + ' ' + $T.mb) 'DarkGray' }
                        $resp = $req.GetResponse()
                        if ($have -gt 0 -and [int]$resp.StatusCode -ne 206) { $have = 0 }       # сервер не умеет докачку - сначала
                        $mode = if ($have -gt 0) { [IO.FileMode]::Append } else { [IO.FileMode]::Create }
                        $out = New-Object IO.FileStream($part, $mode, [IO.FileAccess]::Write, [IO.FileShare]::None)
                        $in = $resp.GetResponseStream()
                        $buf = New-Object byte[] (1MB)
                        $done = $have; $t0 = Get-Date; $start = $have; $lastDraw = [DateTime]::MinValue
                        try {
                            while (($n = $in.Read($buf, 0, $buf.Length)) -gt 0) {
                                $out.Write($buf, 0, $n); $done += $n
                                $now = Get-Date
                                if (($now - $lastDraw).TotalMilliseconds -ge 250 -or $done -ge $size) {
                                    $lastDraw = $now
                                    $pct = [math]::Min(100, $done * 100.0 / $size)
                                    $sec = [math]::Max(0.5, ($now - $t0).TotalSeconds)
                                    $bps = ($done - $start) / $sec
                                    $bar = ('#' * [int]($pct / 2.5)).PadRight(40, '-')
                                    # первые 2 секунды скорость ещё не известна - не показываем ерунду
                                    if ($sec -ge 2 -and $bps -gt 0) {
                                        $eta = [TimeSpan]::FromSeconds([math]::Round(($size - $done) / $bps))
                                        $tail = '{0:N1} {1}  {2} {3:hh\:mm\:ss}' -f ($bps / 1MB), $T.speed, $T.left, $eta
                                    } else { $tail = '' }
                                    $line = ('  [{0}] {1,5:N1}%  {2}/{3} {4}  {5}' -f $bar, $pct, [math]::Round($done / 1MB), [math]::Round($size / 1MB), $T.mb, $tail).PadRight(96)
                                    Write-Host ("`r" + $line) -NoNewline -ForegroundColor Green
                                }
                            }
                        } finally { $out.Close(); $in.Close(); $resp.Close() }
                        Write-Host ''
                        if ($done -gt $have) { $failsNoProgress = 0 }
                    } catch {
                        Write-Host ''
                        $now2 = 0; if (Test-Path $part) { $now2 = (Get-Item $part).Length }
                        if ($now2 -le $have) { $failsNoProgress++ } else { $failsNoProgress = 0 }
                        if ($failsNoProgress -ge 6) { throw $T.net + "`n  " + $_.Exception.Message }
                        $wait = [math]::Min(30, 3 * $failsNoProgress + 2)
                        Say ('  ' + ($T.retry -f $wait, $attempt) + ':  ' + $_.Exception.Message) 'Yellow'
                        Start-Sleep -Seconds $wait
                    }
                }
                if ((Get-Item $part).Length -ne $size) { Remove-Item $part -Force; continue }
                Move-Item $part $zip -Force
            }
            # ---------- 4. проверка ----------
            if (-not $sha) { break }
            Stage $T.verify
            $got = (Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash.ToLower()
            if ($got -eq $sha) { Say '  OK' 'Green'; break }
            Say ('  ' + $T.bad) 'Yellow'
            Remove-Item $zip -Force
            if ($round -eq 2) { throw $T.bad }
        }

        # ---------- 5. распаковка (поверх старой версии) ----------
        while (Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($ExeName)), 'EpicFlail-Win64-Shipping' -ErrorAction SilentlyContinue) {
            if ($Auto) { Get-Process -Name 'EpicFlail', 'EpicFlail-Win64-Shipping' -ErrorAction SilentlyContinue | Stop-Process -Force; Start-Sleep 2; continue }
            Read-Host ('  ' + $T.running) | Out-Null
        }
        Stage $T.unpack
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $stage = Join-Path $dir '_unpack'
        if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $stage | Out-Null
        $za = [IO.Compression.ZipFile]::OpenRead($zip)
        try {
            $files = @($za.Entries | Where-Object { $_.Name })
            $total = 0; foreach ($e in $files) { $total += $e.Length }
            $doneBytes = 0; $lastDraw = [DateTime]::MinValue
            foreach ($e in $files) {
                # внутри архива всё лежит в папке EpicFlail/ - её убираем, игра встаёт прямо в выбранную папку
                $relPath = $e.FullName -replace '^[^/\\]+[/\\]', ''
                $target = Join-Path $stage $relPath
                New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
                [IO.Compression.ZipFileExtensions]::ExtractToFile($e, $target, $true)
                $doneBytes += $e.Length
                if (((Get-Date) - $lastDraw).TotalMilliseconds -ge 250) {
                    $lastDraw = Get-Date
                    $pct = $doneBytes * 100.0 / [math]::Max(1, $total)
                    Write-Host ("`r  [{0}] {1,5:N1}%" -f ('#' * [int]($pct / 2.5)).PadRight(40, '-'), $pct) -NoNewline -ForegroundColor Green
                }
            }
            Write-Host ("`r  [{0}] 100.0%" -f ('#' * 40)) -ForegroundColor Green
        } finally { $za.Dispose() }
        # старую версию убираем (сохранения и настройки игры лежат не здесь, а в %LOCALAPPDATA%\EpicFlail - их не трогаем)
        Get-ChildItem -LiteralPath $dir -Force | Where-Object { $_.Name -notin @('_unpack', '_download') } | Remove-Item -Recurse -Force
        Get-ChildItem -LiteralPath $stage -Force | Move-Item -Destination $dir -Force
        Remove-Item $stage -Recurse -Force
        Set-Content -LiteralPath $verFile -Value $tag -Encoding ASCII
        Remove-Item (Join-Path $dir '_download') -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (-not (Test-Path $exe)) { throw "$ExeName not found in $dir" }

    # ---------- 6. системные библиотеки Microsoft Visual C++ 2015-2022 (x64) ----------
    # Игре на Unreal 5.8 нужен СВЕЖИЙ Visual C++. Наличие vcruntime140_1.dll ничего не говорит: у друга 22.11.2026
    # файлы были (старая версия), а игра при запуске просила установку. Поэтому смотрим версию в реестре.
    $vcOk = $false
    try {
        $k = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64' -ErrorAction Stop
        if ($k.Installed -eq 1 -and [int]$k.Major -eq 14 -and [int]$k.Minor -ge 44) { $vcOk = $true }
    } catch {}
    if (-not $vcOk) {
        Stage $T.prereq
        $pre = Get-ChildItem -LiteralPath $dir -Recurse -Filter 'UEPrereqSetup_x64.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($pre) {
            Start-Process -FilePath $pre.FullName -ArgumentList '/quiet', '/norestart' -Verb RunAs -Wait
        } else {
            # в сборке нет установщика Unreal - берём официальный с сайта Microsoft (всегда последняя версия)
            $vc = Join-Path $env:TEMP 'vc_redist.x64.exe'
            Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $vc -UseBasicParsing -TimeoutSec 300
            Start-Process -FilePath $vc -ArgumentList '/install', '/quiet', '/norestart' -Verb RunAs -Wait
            Remove-Item $vc -Force -ErrorAction SilentlyContinue
        }
    }

    # ---------- 7. ярлыки ----------
    $ws = New-Object -ComObject WScript.Shell
    $lnkPaths = @((Join-Path ([Environment]::GetFolderPath('Desktop')) ($GameName + '.lnk')),
                  (Join-Path ([Environment]::GetFolderPath('Programs')) ($GameName + '.lnk')))
    foreach ($p in $lnkPaths) {
        $l = $ws.CreateShortcut($p)
        $l.TargetPath = $exe; $l.WorkingDirectory = $dir; $l.IconLocation = $exe + ',0'; $l.Description = $GameName
        $l.Save()
    }
    Stage ($T.shortcut + ': ' + $lnkPaths[0])
    Write-Host ''
    Say ($T.done + ' ' + $dir + '   (' + $tag + ')') 'Green'
    if (-not $Auto) {
        $a = Read-Host ('  ' + $T.run)
        if ($a -match '^\s*[YyДдTt]') { Start-Process -FilePath $exe -WorkingDirectory $dir }
    }
    exit 0
} catch {
    Write-Host ''
    Say ('  ' + $T.fail + ': ' + $_.Exception.Message) 'Red'
    Finish 1
}
