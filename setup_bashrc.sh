#!/bin/bash
user=`id -u -n`

echo "# virtualenv and virtualenvwrapper" >> /$user/.bashrc
echo "export WORKON_HOME=$HOME/.virtualenvs" >> /$user/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /$user/.bashrc
echo " " >> /$user/.bashrc
echo "alias showIP=' ifconfig eth0 | sed -n "2s/[^:]*:\([^ ]*\).*/\1/p" '" >> /$user/.bashrc
echo "alias runJupyterNotebook='jupyter notebook --allow-root --ip=172.17.0.2 --port=8888'" >> /$user/.bashrc
source /$user/.bashrc
