######################################################################
echo ----------------------------------------------------------------#
echo -                    Mongo - Ubuntu 20.04                       #
echo ----------------------------------------------------------------#
######################################################################

echo "Installing Mongo On Ubuntu 20.04"
# source:  https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
sudo apt-get install gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
# may need to change on other versions of Ubuntu
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Init System
# To run and manage your mongod process, you will be using your operating system’s built-in init system. 
#Recent versions of Linux tend to use systemd (which uses the systemctl command), while older versions of Linux tend to use System V init (which uses the service command).
# If you are unsure which init system your platform uses, run the following command:
ps --no-headers -o comm 1
# Starts up MongoDB right now
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
#sudo systemctl restart mongod
#mongo

#Uninstall MongoDB
#sudo service mongod stop
#sudo apt-get purge mongodb-enterprise*
#sudo rm -r /var/log/mongodb
#sudo rm -r /var/lib/mongodb

echo "Mongo On Ubuntu 20.04 is up and running"

