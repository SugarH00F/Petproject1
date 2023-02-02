#! /bin/bash
sudo apt-get update
sudo rm -rf /var/www/html/index.html
sudo apt install -y git
git init /home/admin/
sudo git clone https://github.com/AnnaConda007/testForAlex.git /home/admin/testForAlex
sudo mv /home/admin/testForAlex/* /var/www/html/