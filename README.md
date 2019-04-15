# QuickStart
A simple bash script to get an Apache server set up and running quickly.

The script updates the system, installs Apache with the hostname of your choice and a "www" version, then installs CertBot and the CertBot Apache plugin

Options:
-adduser > creates a new user with their home directory, adds the user to sudoers
-cleanstart > uninstalls Apache, CertBot and its plugin as well as all logs and extra folders created by Apache. Then reinstalls everything.