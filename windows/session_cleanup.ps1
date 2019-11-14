# Find running processes
$all = get-process gecko*, firefox*, chrome*

# Find processes running for longer than 20 minutes
if ($all) {
    $old = $all | where { $_.StartTime -lt (Get-Date).AddMinutes(-20) }
    if ($old) {
        $old | stop-process -force
        $message = 'Old sessions deleted: '
        $old | ForEach-Object {
            $message += ($_.ProcessName + " (" + $_.Id + "), ")
        }
    }
    else {
        $message = 'Sessions are running, but none are old: '
        $all | ForEach-Object {
            $message += ($_.ProcessName + " (" + $_.Id + "), ")
        }
    }
}
else {
    $message = 'No running sessions'
    # Clean up temp files
    Set-Location c:\Users
    Remove-Item ".\*\AppData\Local\Temp\*" -Recurse -Force
}

# Create Selenium application in Windows Event Log if it doesn't already exist
if (![System.Diagnostics.EventLog]::SourceExists("Selenium")) {
    New-EventLog -LogName Application -Source Selenium
}

# Write details to the event log
Write-EventLog -LogName Application -Source Selenium -EventID 1001 -EntryType Information -Message $message