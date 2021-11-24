# Filip Liwiński (c) 2021
# https://github.com/filipliwinski/NCSCopyMaker

param (
  [int] $backInTimeInWeeks = -1,
  [bool] $debug = $false
)

# For debugging purposes, assign the base path in the PS Console:
# $basePath = "<script location>"

if ($PSScriptRoot -ne '') {
  $basePath = $PSScriptRoot
}

if ($basePath -eq '') {
  throw "Base path not defined."
}

$config = Get-Content -Path "$basePath\config.json" | ConvertFrom-Json
if (-1 -eq $backInTimeInWeeks) {
  $backInTimeInWeeks = $config.backInTimeInWeeks
}
if ($null -eq $debug) {
  $debug = $config.debug
}

$currentDate = $(Get-Date).Date.AddDays( - (7 * $backInTimeInWeeks))

$futureDeadlines = [ordered]@{}
$pastDeadlines = [ordered]@{}

foreach ($deadline in $config.deadlines) {
  $date = [datetime]::parseexact($deadline, 'dd-MM-yyyy', $null)
  $difference = NEW-TIMESPAN -Start $date -End $currentDate
  
  if ($date -lt $currentDate.AddDays(-1)) {
    $pastDeadlines.Add($difference.Days, $date)
  }
  else {
    $futureDeadlines.Add(-$difference.Days, $date)
  }
}

# Find start day (Monday or past deadline + 1)
$dayOfWeek = (Get-date).DayOfWeek.value__
if ($dayOfWeek -eq 0) {
  $dayOfWeek = 7
}

$monday = $currentDate.AddDays( - ($dayOfWeek - 1))

if ($($pastDeadlines.Values)[$pastDeadlines.Count - 1] -eq $monday) {
  $startDate = $($($pastDeadlines.Values)[$pastDeadlines.Count - 1]).AddDays(1)
}
else {
  $startDate = $monday
}

# Find end day (future deadline or Sunday)
$sunday = $currentDate.AddDays( - ($dayOfWeek - 7))

if ($($futureDeadlines.Values)[0] -lt $sunday) {
  $endDate = $($futureDeadlines.Values)[0]
}
else {
  $endDate = $sunday
}

$diffStartDateString = $startDate.AddDays(-1).Date.ToString("yyyy-MM-dd") # Git start date is one day after specified date
$diffEndDateString = $endDate.Date.ToString("yyyy-MM-dd")
$startDateString = $startDate.Date.ToString("yyyy-MM-dd")
$endDateString = $endDate.Date.ToString("yyyy-MM-dd")

Write-Host "After: $startDate"
Write-Host "Before: $($endDate.AddDays(1))"

# Get week number
$cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
$weekNumber = $cultureInfo.Calendar.GetWeekOfYear($endDate, $cultureInfo.DateTimeFormat.CalendarWeekRule, $cultureInfo.DateTimeFormat.FirstDayOfWeek)
Write-Host "Week number: $weekNumber"

# # Set billing month based on past deadline
# $billingMonth = $startDate.Month
# if ($currentDate -gt $($pastDeadlines.Values)[0] -and $currentDate.Month -lt $($futureDeadlines.Values)[0].Month) {
#   $billingMonth = $startDate.AddMonths(1).Month
# }

# Set billing month based on future deadline
$billingMonth = $($futureDeadlines.Values)[0].Month

# Set and create output path
$folderName = "$((Get-Date).Year).$($billingMonth)"
$diffsFolderName = if ($debug -eq $false) { "diffs" } else { "diffs-debug" } 
$outputPath = "$basePath\$diffsFolderName\$folderName"
if ($config.$outputDirectory) {
  $outputPath = $outputDirectory
}
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null

if ($config.repositories -is [array]) {
    $repositories = $config.repositories
} else {
    $repositories = @()
    $directories = Get-ChildItem -Directory -Path $config.repositories
    foreach ($dir in $directories) {
        $repo = @{
            "location" = "$($config.repositories)\$dir"
            "name" = $dir
        }
        $repositories += $repo
    }
}

# Get diff for each repository
foreach ($repository in $repositories) {
  $diff = git -C $repository.location log -p --all --author="$($config.author)" --after=$diffStartDateString --before=$diffEndDateString --full-diff

  if ($null -ne $diff) {
    Write-Host "Generating diffs for $startDateString - $endDateString in $($repository.name)..."
    $diffOutputPath = "$outputPath\$($repository.name)"
    New-Item -ItemType Directory -Force -Path $diffOutputPath | Out-Null
    $outputFile = "$diffOutputPath\week-$weekNumber.txt"
    $diff > $outputFile
    Write-Host "Saved to: $outputFile"
  }
  else {
    Write-Host "No diffs for $startDateString - $endDateString in $($repository.name)..."
  }
}

if ($config.compress) {
  Compress-Archive -Path "$basePath\$diffsFolderName\$folderName" -DestinationPath "$basePath\$diffsFolderName\$folderName.zip" -Force
  Write-Host "Compressed to: $folderName.zip"
}
