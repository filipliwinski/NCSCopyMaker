# Filip Liwiński (c) 2020
# https://github.com/filipliwinski/NCSCopyMaker

# For debugging purposes, assign the base path in the PS Console:
# $basePath = "<script location>"

if ($PSScriptRoot -ne '') {
  $basePath = $PSScriptRoot
}

if ($basePath -eq '') {
  throw "Base path not defined."
}

$config = Get-Content -Path "$basePath\config.json" | ConvertFrom-Json
$currentDate = Get-Date

$futureDeadlines = [ordered]@{}
$pastDeadlines = [ordered]@{}

foreach ($deadline in $config.deadlines) {
  $date = [datetime]::parseexact($deadline, 'dd-MM-yyyy', $null)
  $difference = NEW-TIMESPAN -Start $date -End $currentDate
  
  if ($date -lt $currentDate.AddDays(-1)) {
    $pastDeadlines.Add($difference.Days, $date)
  } else {
    $futureDeadlines.Add(-$difference.Days, $date)
  }
}

# Find start day (Monday or past deadline + 1)
$dayOfWeek = (Get-date).DayOfWeek.value__
if ($dayOfWeek -eq 0) {
  $dayOfWeek = 7
}

$monday = $currentDate.AddDays(-($dayOfWeek - 1))

if ($($pastDeadlines.Values)[0] -gt $monday) {
  $startDate = $($($pastDeadlines.Values)[0]).AddDays(1)
} else {
  $startDate = $monday
}

# Find end day (future deadline or Sunday)
$sunday = $currentDate.AddDays(-($dayOfWeek - 7))

if ($($futureDeadlines.Values)[0] -lt $sunday) {
  $endDate = $($futureDeadlines.Values)[0]
} else {
  $endDate = $sunday
}

$startDate = $startDate.Date.AddDays(-(7 * $config.backInTimeInWeeks))
$endDate = $endDate.Date.AddDays(-(7 * $config.backInTimeInWeeks))

$startDateString = $startDate.AddDays(-1).Date.ToString("yyyy-MM-dd")
$endDateString = $endDate.Date.ToString("yyyy-MM-dd")

Write-Host "After: $startDate"
Write-Host "Before: $endDate"

# Get week number
$cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
$weekNumber = $cultureInfo.Calendar.GetWeekOfYear($endDate,$cultureInfo.DateTimeFormat.CalendarWeekRule, $cultureInfo.DateTimeFormat.FirstDayOfWeek)
Write-Host "Week number: $weekNumber"

# Set current billing month based on past deadline
$billingMonth = $startDate.Month
if ($currentDate -gt $($pastDeadlines.Values)[0]) {
  $billingMonth = $startDate.AddMonths(1).Month
}

# Set and create output path
$outputPath = "$basePath\copyrights\$($currentDate.Year).$($billingMonth)"
if ($config.$outputDirectory) {
  $outputPath = $outputDirectory
}
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null

# Get diff for each repository
foreach ($repository in $config.repositories) {
  $diff = git -C $repository.location log -p --all --author="$($config.author)" --after=$startDateString --before=$endDateString --full-diff

  if ($null -ne $diff) {
    Write-Host $repository.name
    $diffOutputPath = "$outputPath\$($repository.name)"
    New-Item -ItemType Directory -Force -Path $diffOutputPath | Out-Null
    $diff > "$diffOutputPath\week-$weekNumber.txt"
  }
}