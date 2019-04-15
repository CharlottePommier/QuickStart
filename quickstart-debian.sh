#!/bin/bash

addUser ()
{
echo "Adding new user..."

useradd -m $username -p $password
usermod -aG sudo $username &> /dev/null 
}

setupApacheCertBot ()
{
echo "Updating system, this can take a few minutes..."
apt-get clean all
apt-get -y update &> /dev/null

echo "Installing Apache..."
apt-get -y install apache2 &> /dev/null
systemctl start apache2 &> /dev/null

echo "Creating virtual host..."
mkdir -p /var/www/$domain/html
mkdir -p /var/www/$domain/log
chown -R $username:$username /var/www/$domain/html
chmod -R 755 /var/www

cat <<END > /var/www/$domain/html/index.html 
<html>
<head>
	<title>ACME enrollment demo</title>
</head>
<body>
	<h1 style="font-family:'arial', 'calibri'">$message</h1>
	<img src="https://digicert.com/wp-content/uploads/2018/10/DigiCert-Logo.png">
</body>
</html>  
END

mkdir -p /etc/apache2/sites-available 
mkdir -p /etc/apache2/sites-enabled
chmod -R 755 /etc/apache2/sites-available 
chmod -R 755 /etc/apache2/sites-enabled

cat <<END > /etc/apache2/sites-available/$domain.conf

<VirtualHost *:80>
    ServerName www.$domain
    ServerAlias $domain
    DocumentRoot /var/www/$domain/html
    ErrorLog /var/www/$domain/log/error.log
    CustomLog /var/www/$domain/log/requests.log combined
</VirtualHost>
END

a2ensite $domain &> /dev/null

echo "Restarting Apache..."
systemctl restart apache2 

echo "Installing CertBot..."
apt-get -y install certbot &> /dev/null
echo "Installing Apache plugin for Certbot..."
apt-get -y install python-certbot-apache &> /dev/null
echo "All done! Check $domain in your browser to verify the virtual host is set up correctly. Reminder of the Certbot command line: certbot --apache --server [ACME URL] "
     
}

removeApacheCertBot ()
{
apt-get -y purge apache2 &> /dev/null
rm -rf /etc/apache2
apt-get -y purge certbot python-certbot-apache &> /dev/null
rm -rf /etc/letsencrypt
rm -rf /var/log/letsencrypt
rm -rf /var/lib/letsencrypt
rm -rf ~/.local/share/letsencrypt
}

if [ -z $1 ]
then
        echo "Setting you up for your demo now :)"
		echo "Basic install, just Apache, Certbot and its Apache plugin"
		read -p "What domain will be pointing to your web server?: `echo $'\n> '`" domain
		read -p "Add a custom message to your index.html: `echo $'\n> '`" message
		setupApacheCertBot
	

elif [ $1 == "-adduser" ]
then 
		echo "Setting you up for your demo now :)"
		read -p "Creating a new user with sudo privileges. Enter user name: `echo $'\n> '`" username
		read -p "Choose a password for the new user: `echo $'\n> '`" -s password
		read -p "What domain will be pointing to your web server?: `echo $'\n> '`" domain
		read -p "Add a custom message to your index.html: `echo $'\n> '`" message
		addUser
		setupApacheCertBot
	

elif [ $1 == "-cleanstart" ]
then
		echo "Starting again from scratch!"
		read -p "What domain will be pointing to your web server?: `echo $'\n> '`" domain
		read -p "Add a custom message to your index.html: `echo $'\n> '`" message
		echo "Removing Apache..."
		removeApacheCertBot
		echo "Removing CertBot..."
		setupApacheCertBot
		
elif [ $1 != "-adduser" ] || [ $1 != "-cleanstart" ]
then 
		echo "Sorry I didn't catch that. Did you mean to write '-adduser' or '-cleanstart'? I only know these two."
		
fi