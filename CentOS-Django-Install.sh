#!/bin/sh
# File name: CentOS-Django-Install.sh
# This script is used to install Django 1.8 on CentOS 6.5 automatically.
# Author: Arvin(mikepetermessidona@hotmail.com) twitter(@Messi_Arvin)
# Date:   Mar.09.2017
# Usage:  Save this file as CentOS-Django-Install.sh. 
#         $ chmod u+x CentOS-Django-Install.sh
#	      $ su root
#         # ./CentOS-Django-Install.sh
# Check result:
# [root@donkey opt]# python
# Python 2.7.9 (default, Mar  9 2017, 10:20:35)
# [GCC 4.4.7 20120313 (Red Hat 4.4.7-17)] on linux2
# Type "help", "copyright", "credits" or "license" for more information.
# >>> import django
# >>> django.VERSION
# (1, 8, 0, 'final', 0)
# >>>
#
DIR_PYTHON="/opt/python2.7.9"
CMD_PYTHON="/usr/bin/python"
echo -e "\e[1;33m[INFO]:\e[0m DIR_PYTHON: "$DIR_PYTHON""
echo -e "\e[1;33m[INFO]:\e[0m CMD_PYTHON: "$CMD_PYTHON""

function Django_Install_Func(){
	#Install python packages compiling python source code.
	yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel

	if [ ! -d $DIR_PYTHON ]; then
	  mkdir $DIR_PYTHON
	  echo -e "\e[1;33m[INFO]:\e[0m Directory "$DIR_PYTHON" is created!"
	else
	  echo -e "\e[1;31m[ERROR]:\e[0m Directory "$DIR_PYTHON" existed! Please define a new directory to save python2.7.9 source code."
	  exit 1
	fi
	
	echo -e "\e[1;33m[INFO]:\e[0m Start to upgrade Python!"
	cd $DIR_PYTHON
	wget --no-check-certificate https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz
	tar xf Python-2.7.9.tar.xz

	cd $DIR_PYTHON/Python-2.7.9
	./configure --prefix=/usr/local
	make && make install

	if [ -f $CMD_PYTHON ]; then
	  rm $CMD_PYTHON
	fi
	ln -s /usr/local/bin/python2.7 $CMD_PYTHON

	echo -e "\e[1;33m[INFO]:\e[0m Start to modify yum!"
	CMD_YUM=`which yum`
	echo -e "\e[1;33m[INFO]:\e[0m CMD_YUM: "$CMD_YUM""
	LINE_YUM=`awk '/#!\/usr\/bin\/python/{print NR}'  /usr/bin/yum`
	sed -i "$LINE_YUM c #!/usr/bin/python2.6" $CMD_YUM           

	yum install python-devel
	yum install python-pip

	echo -e "\e[1;33m[INFO]:\e[0m Start to modify pip!"
	CMD_PIP=`which pip`
	echo -e "\e[1;33m[INFO]:\e[0m CMD_PIP: "$CMD_PIP""
	LINE_PIP=`awk '/python2.6\/site-packages/{print NR}'  "$CMD_PIP"`
	if [ ! $LINE_PIP ]; then
	  sed -i "/import sys/a\sys.path.append('/usr/lib/python2.6/site-packages')" $CMD_PIP
	  echo -e "\e[1;33m[INFO]:\e[0m Append python2.6/site-packages!"
    else
	  echo -e "\e[1;33m[INFO]:\e[0m python2.6/site-packages existed!"
    fi
	
	echo -e "\e[1;33m[INFO]:\e[0m Start to install Django!"
	pip install Django==1.8
	echo -e "\e[1;33m[INFO]:\e[0m Django is installed!"
}
  
PYTHON_VERSION=$(python -V 2>&1 >/dev/null)
echo -e "\e[1;33m[INFO]:\e[0m PYTHON_VERSION: "$PYTHON_VERSION""

if [[ "Python 2.6.6" == $PYTHON_VERSION ]]; then
  Django_Install_Func
else
  echo -e "\e[1;31m[ERROR]:\e[0m Current python version is: $PYTHON_VERSION, please modify this script."
fi
