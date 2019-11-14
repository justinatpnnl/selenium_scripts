# Setting Up Selenium Grid

To provide some redundancy and scale for our web page monitoring, we implemented a Selenium Grid.  The first iteration of our Selenium monitoring used a Windows 7 VM running a Splunk Universal Forwarder to schedule the input script and send the data to our indexers.  This script controlled the browsers locally, so the Selenium Standalone Server and Java Runtime Environment (JRE) were not required.

Although this worked well for a couple of years, the downside to this approach was we had a single point of failure and lack of scaleability.  To improve reliability and scale, we began looking into configuring a Selenium Grid.  

## Components

There are a number of ways a Selenium Grid can be configured.  Our configuration looks like this:

**Splunk Search Head** 

Running custom Web Monitoring app for configuring new tests, displaying results, and alerting site owners.

**Selenium Hub Server**

Windows Server 2016 system running as a Splunk Heavy Forwarder and configured as the Selenium Hub.  There is a scripted input that reads the tests from the KV Store on the Splunk Search Head and runs them, distributing them to the registered nodes.

**Selenium Nodes**

Our initial setup had two Windows 10 systems configured as Selenium Nodes making two instances each of Firefox and Chrome.  These are both registered with the Selenium Hub server.



## Selenium Grid Hub

#### Step 1: Install Dependencies

**Java Runtime Environment (JRE)**

To use Selenium Webdriver Remote, you need the Selenium Standalone Server .jar file. This requires a Java Runtime Environment (JRE) to be installed.

**Selenium Standalone Server**

You can download Selenium Standalone Server from https://www.seleniumhq.org/download/.  The download is in the form of a `.jar` file.  Save this file in a location to reference in your setup script.

Example: `c:\selenium\selenium-server-standalone-3.141.59.jar`



#### Step 2: Configure the Hub Startup Command

Starting the hub can be done from the command line, but you'll probably want to script it and created a scheduled task that starts the hub when Windows starts.  This can be a very minimalistic command:

```
java.exe -jar c:\selenium-server-standalone-3.141.59.jar -role hub
```

There are more configuration options available.  You can view the list of available options from the command line by adding `-help`:

```
java.exe -jar c:\selenium-server-standalone-3.141.59.jar -role hub -help
```

Some options you might consider for your hub configuration:

***browserTimeout*** - The number of seconds a browser session is allowed to hang while a WebDriver command is running ( example: `driver.get(url)` ). If the timeout is reached while a WebDriver command is still processing, the session will quit. Minimum value is 60. An unspecified, zero, or negative value means wait indefinitely. If a node does not specify it, the hub value will be used.

```
-browserTimeout 60
```

***port*** - By default the hub will be accessible on port 4444.  If you want to specify the port, you can add the `-port` option:

```
-port 1234
```



#### Step 3: Schedule Startup Task

1. Create a scheduled task with the `Start a program` action.  Fill out the following two fields:

* **Program/Script**:  java.exe
* **Add arguments:**  The rest of your command line config.  Sample:  `-jar c:\selenium-server-standalone-3.141.59.jar -role hub`

2. Create a trigger that runs it at startup.

Once your task is created, run it manually to make sure everything is working as expected.  If it is, you should be able to view the grid console at http://localhost:4444/grid/console.



#### Step 4: Firewall configuration

**Inbound**

You will need to make port 4444 (or whichever port you specified) accessible from the Splunk Search Head for the monitoring app to be able to test new sites as you add monitoring, and from the Selenium Nodes.

**Outbound**

The Selenium Hub server will need to be able to talk to the Selenium Nodes over port 5555 (default for nodes, can be specified differently)



## Selenium Grid Nodes

#### Step 1:  Install Dependencies

**Java Runtime Environment (JRE)**

To use Selenium Webdriver Remote, you need the Selenium Standalone Server .jar file. This requires a Java Runtime Environment (JRE) to be installed.

**Selenium Standalone Server**

You can download Selenium Standalone Server from https://www.seleniumhq.org/download/.  The download is in the form of a `.jar` file.  Save this file in a location to reference in your setup script.**

Example: `c:\selenium\selenium-server-standalone-3.141.59.jar`

**Browsers**

You will need to have the browsers installed that you intend to use for testing.  The version of Chrome you install will have a corresponding ChromeDriver version to ensure compatibility.

Firefox is less picky about the driver version, you will just need a recent version of Firefox installed (>=60).

**WebDrivers**

The list of available WebDrivers is available at https://www.seleniumhq.org/download/

* You can download the latest ChromeDriver from https://sites.google.com/a/chromium.org/chromedriver/downloads. 
* You can download the latest GeckoDriver for Firefox from https://github.com/mozilla/geckodriver/releases.  

Save the drivers in a location to reference in your setup script, likely in the same location as the Selenium Standalone Server file.  For clarity, I will usually append the version number to the file name:

Example: `c:\selenium\chromedriver77.exe`



#### Step 2: Configure the Node Startup Command

Like the hub, starting the node can be done from the command line.  There are a lot more configuration options needed:

```
java.exe
-Dwebdriver.chrome.driver=C:\Selenium\chromedriver77.exe 
-Dwebdriver.gecko.driver=C:\Selenium\geckodriver26.exe 
-jar c:\selenium\selenium-server-standalone-3.141.59.jar 
-role node 
-hub http://<your hub server>:4444/grid/register 
-browser "browserName=chrome,maxInstances=2" 
-browser "browserName=firefox,maxInstances=2"
```

**Options Explained**

***-Dwebdriver.<browser>.driver*** - Specifies the location of the WebDriver files

***-hub*** - This should be the hostname:port you configured for the hub

**-browser** - For each browser, allows you to specify the maximum available instances

There are more configuration options available, visible from the comand line:

```
java.exe -jar c:\selenium-server-standalone-3.141.59.jar -role node -help
```

Some options you might consider for your hub configuration:

***-host*** - Allows you specify a host name so that it shows up in the Grid Console by name instead of by ip.

***-port*** - The default port for nodes is 5555.  You can specify your own.



#### Step 3: Set up a Scheduled Task

1. Create a scheduled task with the `Start a program` action.  Fill out the following two fields:

* **Program/Script**:  java.exe
* **Add arguments:**  The rest of your command line config from Step 2.

2. Create a trigger that runs it at startup.

Run your test manually to make sure it works as expected.



#### Step 4: Firewall Configuration

**Inbound**

You will need to make port 5555 (or whichever port you specified) accessible from the Selenium Grid Hub.

**Outbound**

The Selenium Nodes will need to be able to talk to the Selenium Hub over port 4444 (Or your custom configured port)



#### Step 5: Create a cleanup task

As an optional final step, there is a PowerShell script in the `./windows` directory of this project called `session_cleanup.ps1`. This script looks for any running Firefox and Chrome browsers processes and their drivers and determines if they are stale.  Sessions are determined to be stale if they have running for more than 20 minutes.  

In addition to killing the stale processes, an event is logged with the details of the actions performed when the script runs.

If no running sessions are found, it takes the opportunity to clear temp files that are often generated from the browser sessions.

This script was designed to be used in a Scheduled Task that can run every 15 minutes.

Setting up repeated tasks can be tricky, so I created another PowerShell script called `ScheduleCleanup.ps1` which will create the scheduled task for you.



## Testing

At this point you should have a working Selenium Hub with your Nodes registered.  You can confirm this by going to http://localhost:4444/grid/console.  Each node you configured should now appear in the console with the configured browser instances displayed.



## Resources

Below are some resources that I found usefull on this journey.  I found the documentation for setting up a Selenium Grid a little sparse for my liking, and these resources helped me to find the right path.  Some of these references are for older versions of Selenium.

**SeleniumHQ**

First, the available documentation from the SeleniumHQ page itself.  Some of it is pretty outdated, but much of the data is still relevant.

https://www.seleniumhq.org/docs/07_selenium_grid.jsp

https://github.com/SeleniumHQ/selenium/wiki/Grid2



**Test Guild**
Joe Colantonio - October 7, 2014

A good overview of what Selenium Grid is, and instructions for setting up a Selenium Grid with an older version of Selenium.  

https://testguild.com/selenium-grid-how-to-setup-a-hub-and-node/



**Selenium Grid – Test Execution in Cluster**
NPNTraining.com - November 29, 2018

Some great details on setting up the Hub and Nodes, with some descriptions included of various options available.  Also describes how to use a JSON configuration file

https://www.npntraining.com/blog/selenium-grid-test-execution-in-cluster-part-2/



**Configuring Chrome and Firefox for Windows Integrated Authentication**
SpecOpsSoft.com - March 14, 2017

If you are using Windows Integrated Authentication to allow your test systems to access internal web pages, your test browsers will likely need to be configured before it will work correctly.  This article got me going in the right direction.

https://specopssoft.com/blog/configuring-chrome-and-firefox-for-windows-integrated-authentication/


## Notice

This material was prepared as an account of work sponsored by an agency of the United States Government. Neither the United States Government nor the United States Department of Energy, nor the Contractor, nor any or their employees, nor any jurisdiction or organization that has cooperated in the development of these materials, *makes any warranty, express or implied, or assumes any legal liability or responsibility for the accuracy, completeness, or usefulness or any information, apparatus, product, software, or process disclosed, or represents that its use would not infringe privately owned rights*.

Reference herein to any specific commercial product, process, or service by trade name, trademark, manufacturer, or otherwise does not necessarily constitute or imply its endorsement, recommendation, or favoring by the United States Government or any agency thereof, or Battelle Memorial Institute. The views and opinions of authors expressed herein do not necessarily state or reflect those of the United States Government or any agency thereof.

**PACIFIC NORTHWEST NATIONAL LABORATORY**
*operated by*
**BATTELLE**
*for the*
**UNITED STATES DEPARTMENT OF ENERGY**
*under Contract DE-AC05-76RL01830*
