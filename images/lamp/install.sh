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

mkdir -p /run/nginx
mkdir -p /var/www

cat << 'EOF' > /var/www/index.php
<?php 
$mc = new Memcached();
$mc->addServer("127.0.0.1", 11211);
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
nginx -g "daemon off;"
EOF
chmod +x /entrypoint

# the following is provided in the lxc alpine image
if [ -n "$(which rc-update)" ]; then
  rc-update add php-fpm
  rc-update add nginx
fi
