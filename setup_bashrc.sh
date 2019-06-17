#!/bin/bash
user=`id -u -n`

echo "# virtualenv and virtualenvwrapper" >> /home/$user/.bashrc
echo "export WORKON_HOME=$HOME/.virtualenvs" >> /home//$user/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/$user/.bashrc
echo " " >> /home/$user/.bashrc
echo "alias showIP=' ifconfig eth0 | sed -n "2s/[^:]*:\([^ ]*\).*/\1/p" '" >> /home/$user/.bashrc
echo "alias runJupyterNotebook='jupyter notebook --allow-root --ip=172.17.0.2 --port=8888'" >> /home/$user/.bashrc
source /home/$user/.bashrc
