# Selenium Helper Scripts for Mac

While using a Mac for development of Splunk apps and testing Selenium Grid, I documented some setup steps and created some helper scripts.  This allows me to have all of the components I need for testing:

* Splunk Enterprise
* Selenium Grid
  * Selenium Hub
    * http://localhost:4444
  * Selenium Node
    * Registered to the local Selenium Hub
    * Two instances of Firefox and Chrome



## start.sh

This is a simple bash script I use for local testing and development on a Mac.  It mimics a remote Selenium Grid Hub configuration and registers a Selenium Node with two Firefox and two Chrome instances.

**Usage**
```
./start.sh
```

Once run successfully, you can access the Selenium Grid Console at http://localhost:4444/grid/console



## Dependencies

The dependencies below need to be installed or copied to the specified locations.

#### Java Runtime Environment (JRE)

To use Selenium Webdriver Remote, you need to run the Selenium Standalone Server. This requires a Java Runtime Environment (JRE) to be installed.

#### Selenium Standalone Server

You can download Selenium Standalone Server from https://www.seleniumhq.org/download/.  The download is in the form of a `.jar` file.  The `start.sh` script expects it to be located in the same directory.

**Version used in this script:** 3.141.59

#### Google Chrome Driver

You can download the latest ChromeDriver from https://sites.google.com/a/chromium.org/chromedriver/downloads.  The `start.sh` script expects it to be located in the `webdrivers` subdirectory. As a practice, I usually append the version number to the file name for clarity:

**Example:** `mac/webdrivers/chromedriver77`
**Version used in this script:** 77.0.3865.40

*NOTE:*
You will also need to have a compatible version of Google Chrome installed. Each version of Chrome has a corresponding version of ChromeDriver.

#### Mozilla GeckoDriver

You can download the latest GeckoDriver from https://github.com/mozilla/geckodriver/releases.  The `start.sh` script expects it to be located in the `webdrivers` subdirectory. Version number appended to the file name for clarity:

**Example:** `mac/webdrivers/geckodriver26`
**Version used in this script:** 0.26.0

*NOTE:*
You will also need to have a recent version of Firefox installed (>=60)