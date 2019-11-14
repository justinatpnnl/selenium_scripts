# Selenium Helper Scripts for Windows

Because our primary user base is in Windows, we chose to set up our Selenium Grid nodes using Windows 10.  This is not a requirement, each node can be a different operating system with different browsers configured.  It is even possible to specify the operating system you want to test on when building selenium tests, and the Selenium Hub will distribute the tests to the appropriate node.

## session_cleanup.ps1

PowerShell script that looks for orphaned processes left behind from Selenium scripts. The  Often times the driver or browser processes do not close successfully.  This can cause browser instances to not be released for Selenium Grid, or can take up memory and cpu resources unnecessarily.

This script looks for any running Firefox and Chrome browsers processes and their drivers and determines if they are stale.  Sessions are determined to be stale if they have running for more than 20 minutes.  

In addition to killing the stale processes, an event is logged with the details of the actions performed when the script runs.

If no running sessions are found, it takes the opportunity to clear temp files that are often generated from the browser sessions.

This script was designed to be used in a Scheduled Task that can run every 15 minutes.

## ScheduleCleanup.ps1

This is a helper script to automatically set up your scheduled task for the `session_cleanup.ps1` script above.


## Dependencies

The dependencies below need to be installed or copied to the specified locations.

### Java Runtime Environment (JRE)

To use Selenium Webdriver Remote, you need to run the Selenium Standalone Server. This requires a Java Runtime Environment (JRE) to be installed.

### Selenium Standalone Server

You can download Selenium Standalone Server from https://www.seleniumhq.org/download/.  The download is in the form of a `.jar` file. The PowerShell scripts referenced in this documentation expect it to be located in the same directory as the scripts.

**Version used in these scripts:** 3.141.59

### Google Chrome Driver

You can download the latest ChromeDriver from https://sites.google.com/a/chromium.org/chromedriver/downloads.  The scripts expect it to be located in the `webdrivers` subdirectory.  As a practice, I usually append the version number to the file name for clarity.

**Example:** `windows/webdrivers/chromedriver77.exe`
**Version used in this script:** 77.0.3865.40

*NOTE:*
You will also need to have a compatible version of Google Chrome installed. Each version of Chrome has a corresponding version of ChromeDriver.

#### Mozilla GeckoDriver

You can download the latest GeckoDriver from https://github.com/mozilla/geckodriver/releases.  The scripts expect it to be located in the `webdrivers` subdirectory.  Version number appended to the file name for clarity.

**Example:** `mac/webdrivers/geckodriver26.exe`
**Version used in this script:** 0.26.0

*NOTE:*
You will also need to have a recent version of Firefox installed (>=60)