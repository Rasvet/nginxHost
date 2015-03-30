#!/bin/bash
if [ $(id -u) != 0 ]; then
  echo “This script must be run as root” 2>&1
  exit 1
fi
#Check input arguments, set values
if [ $# = 0 ]; then
  echo "-n argument required";
  exit 1;
fi

adddir=false;
addlog=false;
project_path=$(dirname $(readlink -f $0));
www_path=/var/www;
tplfile=$project_path/vhost.tpl;
indexfile=$project_path/index.html;

deletehost() {
  source=$2/$1;
  hosts=`sed "/127\.0\.0\.1.*$1\.lc/d" /etc/hosts`;
  echo "$hosts" > /etc/hosts;
  rm -fv /etc/nginx/sites-available/$1.lc && unlink /etc/nginx/sites-enabled/$1.lc;
  if [ -d $source ]; then
    read -p "Shall delete source files ? $source (y - yes)" confirm;
    if [ $confirm = 'y' ]; then
      rm -rv $source;
    fi
  fi
  service nginx restart;
}

while getopts n:dlD: opt; do 
  case "${opt}" in 
    n) name="$OPTARG";; 
    d) adddir=true;; 
    l) addlog=true;;  
    D) deletehost $OPTARG $www_path;
	exit 1;
      ;;
    \?) echo "Invalid option: -$OPTARG" >&2;
	exit 1;
	;;
    :)  echo "Option -$OPTARG requires an argument." >&2
	exit 1;
	;;
    esac 
done

#process the template , replace hostname
tpl=`sed s/{{name}}/$name/g $tplfile`;
## if -d - make a new directory in /var/www
if [ $adddir = true ]; then
  mkdir -v -m 0774 $www_path/$name && chown mkardakov:www-data $www_path/$name;
  cp -v $indexfile $www_path/$name/index.html && chown mkardakov:www-data $www_path/$name/index.html;
fi
# if -l - error and access log enabled
if [ $addlog = true ]; then
  tpl=`echo "$tpl" | sed -e 's/#\([a-z]*_log\)/\1/g'`
fi

# write new vhost file to nginx configs
echo "$tpl" > /etc/nginx/sites-available/$name.lc && \
  ln -s /etc/nginx/sites-available/$name.lc /etc/nginx/sites-enabled/$name.lc;

# update /etc/hosts file add new row
echo -e "\r\n127.0.0.1\t$name.lc" >> /etc/hosts;

service nginx restart;


