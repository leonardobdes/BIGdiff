#  BIGdiff
## About
This is a bash script to help when doing changes to F5 devices.\
The script will collect the status of the objects before and after the change, compare them and produce an HTML file with the results.\
Examples of objects are LTM virtual servers and GTM wide IPs.\
The script will also create the files you will need in case things go wrong (UCS/QKView/Logs).


The most common scenario to use the script will be an upgrade.\
You run the script before the upgrade, upgrade the device, and run the script again.\
The HTML file will give you the results, and it will indicate if something when down after the upgrade.


You can also use the script when copying the configuration from one device to another (configuration migration).\
Also, consolidation, when copying the configuration from multiple devices to a single device.


Lastly, you can use the script in any scenario where you think that could be an impact on the F5 device.\
Let’s assume you are doing major routing changes to your network, and there is a possibility things go down on the F5 devices.\
You can run the script before those changes, perform the changes, and run the script again.\
The HTML file will give you the results, and it will indicate if something changed after you performed the change.


**Important Note: If you have a high availability (HA) pair or a device group with more than 2 devices, each device performs monitoring independently. This means you need to run the script on each device.**


## Usage


1. Download the file bigdiff.sh
2. Create a folder on the device\
**Important Note: Create inside of the folder /shared/tmp/ as the /shared/ is shared between volumes.**
    ```
    mkdir /shared/tmp/bigdiff/
    ```

3. Copy bigdiff.sh to the new folder

4. Change the file permission to allow it to run

    ```
    chmod +x bigdiff.sh
    ```

5. Run the script

    ```
    ./bigdiff.sh
    ```


## Menu Mode

To run the script in menu mode just run the script without any option:

```
./bigdiff.sh
```


Menu mode will present the following menu:

![](/images/menu_mode.png)

Options:
1. Run before change
This option will create the backup files (UCS/QKView/Logs) and will generate a text file with the status of the objects.
2. Run after change
This option will create the backup files (UCS/QKView/Logs) and will generate a text file with the status of the objects.
It will also compare this text file with the file created before, and generate an HTML file with the results.
3. Run before change without backup.
This option will generate a text file with the status of the objects.
As the name indicates, it will not generate backup files (UCS/QKView/Logs).
4. Run after change without backup.
This option will generate a text file with the status of the objects.
It will also compare this text file with the file created before, and generate an HTML file with the results.
As the name indicates, it will not generate backup files (UCS/QKView/Logs).
5. Generate backup files
This option will create backup files (UCS/QKView/Logs).
6. Generate UCS file
This option will create a UCS file that can be used to restore the device in case things go wrong.
7. Generate QKView file
This option will create a QKView file that can be used for troubleshooting or to work with F5 support.
8. Generate full logs file
This option will create a file with all logs files from the folder /var/log/ that can be used for troubleshooting or to work with F5 support.
9. Script information
Provides information about the author, version, and the date the script was written.
10. Version support
Provides information about which versions were tested with the script.


## Silent Mode


Silent mode is for advanced users, or for automation.\
The script will not show error messages, you will need to get the error code via the Bash exit status variable $?.\
It will output the name of the files created, to help with the automation.

To run the script in silent mode just run the script with an option.\
Example, help option:

```
./bigdiff.sh --help
```

If you run the above command, you will be presented with the following text:

![](/images/silent_mode.png)


Majority of the options exist in menu mode, and the functionality will be the same.\
I will explain only the ones that are specific to silent mode.


Options:
* debug – This option allows running the script against files created on other devices for troubleshooting.
The script will load the files from the local folder, files with name “-before-” and “-after-”, and generate an HTML file with the results.
* Error – This option will list the error codes and their respective number.


## HTML File


The script will compare each object and produce an HTML file with the results.\
It will always produce information about LTM module, but it will only show GTM module information if either GTM and/or LC are provisioned.


The information is provided using HTML tables.\
The script uses DataTables (https://datatables.net/) to create dynamic tables.\
DataTables uses jQuery (https://jquery.com/) internally.\
When opening the HTML file, the browser will download the required files from DataTables and  jQuery CDN networks automatically.\
If the downloads fail, you don’t have Internet access as an example, the browser will show static HTML tables instead.


The first part of the file will indicate if any change on the status of the objects, or the number of objects, occurred.\
Also, the number of changes found.


Example without changes:

![](/images/html_file_1.png)

Example with changes:

![](/images/html_file_2.png)


Next, the file will present a table that shows how many objects the script counted before and after the change, grouping them by object type.


Example without changes:

![](/images/html_file_3.png)

Example with changes:

![](/images/html_file_4.png)


Lastly, the file will present a table per object type, indicating their status and if they were enabled or disabled before and after the change.


Example without changes:

![](/images/html_file_5.png)

Example with changes:

![](/images/html_file_6.png)


For a full HTML example file, download the following files:


Example without changes:

![](/html/LABBIGIP1.lab.local-html-20200403094559.html)

Example with changes:
![](/html/LABBIGIP1.lab.local-html-20200403144617.html)


## BIGdiff Remote


This is an extra script that allows you to run BIGdiff remotely, using SSH to connect to the devices and SCP to transfer files.
The script automates all required tasks, including transferring bigdiff.sh file to the remote devices, copying all files created by BIGdiff, and removing files after.

**Important Note: BIGdiff Remote uses sshpass (https://linux.die.net/man/1/sshpass) internally, make sure sshpass is installed to use the script.**


Usage:
1. Download the file bigdiff_remote.sh
2. Change the file permission to allow it to run
    ```
    chmod +x bigdiff_remote.sh
    ```
3. Run the script (make sure you also have bigdiff.sh file in the same folder)
    ```
    ./bigdiff_remote.sh --option file
    ```


Options:
* --option – This will be the option that will be used when running BIGdiff.
Valid options to run BIGdiff remotely are:
--before --after --before-without --after-without --backup --ucs --qkview --logs
* file – This is the file with the list of devices, one per line, you can use IP or name.


Example:
![](/images/bigdiff_remote.png)

## VIPRION

I don’t have a VIPRION system for tests at the moment, but I will make some improvements when I have access to one.


A QKView should be generated in the primary blade to include inside a QKView per blade, so I would like the script to test that and alert if that is not the case.


Each blade generates logs, so in a VIPRION chassis with 2 or more blade the full logs option should generate a full logs file per blade and zip them in a single file.


For UCS that is not relevant as all blades have the same configuration.


The above improvements apply to multi-blade VIPRIONs, or vCMP guests using 2 or more blades.
A vCMP guest with 2 or more blades behaviours the same way as a virtual multi-blade VIPRION in this context.


## Bugs

The following bugs exist on the BIG-IP versions this script supports.
For some of them, I could create a workaround, for others was not possible.


[K14618: The SNMP table index may be generated incorrectly](https://support.f5.com/csp/article/K14618)
If you have LTM pools with large names, and are using the following versions:
11.0.0 11.1.0 11.2.0 11.2.1 11.3.0
The system will not return the correct name for the pool member in that pool when queried using SNMP.
The script will warn you about that and will just skip those pool members.

**GTM Links (no bug id or solution)**
No GTM link listed in 11.0.0.
F5 device does not return the list of GTM links in version 11.0.0.
The problem does not exist on the following tested version:
11.3.0, 12.0.0, 13.1.0.1, 14.0.0, 15.1.0
It probably applies to versions between 11.0.0 and 11.2.0.


[Bug ID 740543: System hostname not display in console](https://cdn.f5.com/product/bugtracker/ID740543.html)
The files created by the script may have the name localhost.localdomain instead of the correct device name.


To report new bugs, or request for enhancement (RFE), please use the issues section on GitHub.

## Author

Name: Leonardo Souza
LinkedIn: https://uk.linkedin.com/in/leonardobdes
