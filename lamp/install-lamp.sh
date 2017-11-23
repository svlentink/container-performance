#!/bin/sh

apk add --no-cache \
  nginx php7 php7-fpm

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

apk add --no-cache \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  php7-memcached

mkdir -p /var/www

cat << 'EOF' > /var/www/index.php
<?php 
$mc = new Memcached();
$mc->addServer("memhost", 11211);
$previous = $mc->get("last");
$current = $_GET["param"];
$mc->set("last", $current); 
$arr = array("previous" => $previous, "current" => $current);
var_dump($arr);
?>
EOF

cat << EOF  > /entrypoint.sh
#!/bin/sh
php-fpm7
nginx -g "daemon off;"
EOF
chmod +x /entrypoint.sh

