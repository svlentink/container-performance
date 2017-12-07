#!/bin/sh -ex

apk add --no-cache \
  nginx
apk add --no-cache \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  php7-memcached php7 php7-fpm

cat << EOF > /etc/nginx/conf.d/default.conf
server {
  listen 80 default_server;
  root /var/www;
  location / {
    fastcgi_pass 127.0.0.1:9000;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /var/www/index.php;
  }
}
EOF

mkdir -p /var/www

cat << 'EOF' > /var/www/index.php
<?php 
$mc = new Memcached();
$mc->addServer("memcache-on-host", 11211);
$previous = $mc->get("last");
$current = $_GET["param"];
$mc->set("last", $current); 
$arr = array("previous" => $previous, "current" => $current);
var_dump($arr);
?>
EOF

cat << EOF  > /entrypoint
#!/bin/sh
php-fpm7
EOF
if grep -q container=lxc /proc/1/environ ; then
  echo 'ip a a 10.0.3.123/24 dev eth0' >> /entrypoint
  echo -e '\n10.0.3.1 memcache-on-host' >> /etc/hosts
else
  echo -e '\n127.0.0.1 memcache-on-host' >> /etc/hosts
fi
cat << EOF  >> /entrypoint
mkdir -p /run/nginx
nginx -g "daemon off;"
EOF
chmod +x /entrypoint

# the following is provided in the lxc alpine image
if [ -n "$(which rc-update)" ]; then
#  rc-update add php-fpm7
#  rc-update add nginx
  ln -fs /entrypoint /sbin/init #the lxc way
fi
