# BIGdiff

Problem this snippet solves:

Allow you compare LTM and GTM objects.
You run the script before and after the upgrade, and the script will generate a report in HTML format showing the results.
The HTML file provides table filter functionality, using the TableFilter (http://koalyptus.github.io/TableFilter/) JavaScript library.

Versions 11.x.x/12.x.x/13.x.x/14.x.x were tested and are supported.
As new versions are released, I will be testing to see if any change is needed to support that version.

How to use this snippet:

Download the tablefilter.js file above, if you want to use the table filter functionality.
Download the bigdiff.sh that is the script file.

In the F5 device, create a folder in /shared/tmp, as /shared is shared between all volumes.
Upload the file bigdiff.sh to the F5 device.

Change the file permission to run:
chmod +x bigdiff.sh
Run the script:
./bigdiff.sh

Run the script before the upgrade.
Upgrade the F5 device.
Run the script after the upgrade.

Download the file ending in .html from the F5 device.
Open the HTML file with your favourite browser.
Make sure you have the tablefilter.js in the same folder as the HTML file, if you want the filter functionalities.

If you want to integrate the script with other tools, use the silent mode.
Run the following command, to get more information:
./bigdiff.sh -h
This will provide you the error code, where 0 means no error:
echo $?

Known Issues:

Large LTM Pool Name - BUG ID 364556

https://support.f5.com/csp/article/K14618
If you have pools with large names, and are using versions:
11.0.0 11.1.0 11.2.0 11.2.1 11.3.0
The system will not return the correct name for the pool member in that pool when queried using SNMP.
The script will warn you about that and will just skip those pool members.

GTM Links

I could not find a bug ID for this yet.
The system will not return the list of GTM links when queried using SNMP.
Found in 11.0.0, not present in 12.0.0, 13.0.0, or 14.0.0.
The script will not list GTM links.
