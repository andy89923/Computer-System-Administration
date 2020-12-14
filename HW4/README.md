2020 NCTU SA nginx
===
##### 2020.12.11
###### tags: `SA` `NCTU`

## Install & Setup
[REF1](https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/)
[REF2]()
```
$ sudo pkg install nginx
```

*/etc/rc.conf*
```
nginx_enable="YES"
```

*/usr/local/etc/nginx/nginx.conf*
```nginx
http {
    server_tokens off;    # hide nginx version in header 
}
```

#### Use curl to test connection
```
$ curl 150.nctu.cs
$ curl --http2 -v 150.nctu.cs
```
[curl](https://snippetinfo.net/mobile/media/2222)
[Chrome](https://superuser.com/questions/1359755/trust-self-signed-cert-in-chrome-macos-10-13)

## Password Authentication
[REF1](https://www.ionos.com/community/server-cloud-infrastructure/nginx/set-up-password-authentication-with-nginx/)
[REF2]()

*/usr/local/etc/nginx/.htpasswd*

```
$ sudo sh -c "echo -n 'admin:' >> .htpasswd"
$ sudo sh -c "openssl passwd -apr1 >> .htpasswd" 
   (this would prompt you to enter password)
```

*/usr/local/etc/nginx/nginx.conf*
```nginx
location /private {
    auth_basic "restricted";
    auth_basic_user_file /usr/local/etc/nginx/.htpasswd;
    try_files /private/secret.html $uri/ =404;
}
```

## SSL & http2
[REF1](https://blog.niclin.tw/2019/08/16/creating-self-signed-certificate-using-openssl/)
[REF2](https://xyz.cinc.biz/2017/06/nginx-https-ssl.html)
```
$ openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /usr/local/www/sahw4/ssl/sa.key -out /usr/local/www/sahw4/ssl/sa.crt
```
```nginx
server {
    listen 443 ssl http2;
    
    ssl_certificate /usr/local/www/sahw4/ssl/sa.crt;
    ssl_certificate_key /usr/local/www/sahw4/ssl/sa.key;
    ssl_protocols TLSv1.2;
}
```
#### Redirect all HTTP requests to HTTPS
```nginx
server {
    listen 80;
    return 301 https://$hosts$request_uri;
}
```

#### HSTS
[Setup](https://www.nginx.com/blog/http-strict-transport-security-hsts-and-nginx/)
[Check HSTS](https://ithelp.ithome.com.tw/articles/10248473)
```nginx
server {
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

#### CORS & HEADER
[Allow HTTP Method](https://geekflare.com/enable-cors-apache-nginx/)
[X-XSS-Protection & X-Frame](https://wiki.crashtest-security.com/enable-security-headers)

##### Allow only four HTTP method: GET, HEAD, POST, OPTIONS
```nginx
server {
    add_header Access-Control-Allow-Origin "150.nctu.cs" always;
    add_header X-Frame-Options "sameorigin" always;
    add_header Access-Control-Allow-Methods "GET, HEAD, POST, OPTIONS" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### PHP / PHP-FPM
[REF](https://www.cyberciti.biz/faq/freebsd-install-php-7-2-with-fpm-for-nginx/)
```
$ sudo pkg install php74
$ sudo pkg install php74-pdo_sqlite (Wordpress would use this)
$ sudo pkg install php74-mysqli
```
##### download all these packages
#### php74-{}
[REF](https://devopscraft.com/how-to-install-wordpress-on-freebsd-12/)
```
mysqli
json
php74-zlib
...
```
*/etc/rc.conf*
```
php_fpm_enable="YES"
```
Start php-fpm service
```
$ sudo service php-fpm start
```

*/usr/local/etc/php-fpm.d/www.conf*
```
listen.owner = www
listen.group = www
listen.mode = 0660
listen = /var/run/php74-fpm.sock
```

*/usr/local/www/sahw4/dns/info-150.php*
```php
<?php phpinfo(); ?>
```

Add another location in *nginx.conf*
```nginx
location /info-150.php {
    fastcgi_pass unix:/var/run/php74-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;
}
```

#### Hide php version in header
[REF](https://www.tecmint.com/hide-php-version-http-header/)
```
$ cp -v /usr/local/etc/php.ini-production /usr/local/etc/php.ini
```
*php.ini*
```
expose_php = off
```


## MySQL
#### Install mysql 8.0
```
$ sudo pkg install mysql80-server
$ sudo service mysql-server start
```

#### Setting
[Password Poilcy](https://tecadmin.net/change-mysql-password-policy-level/)
```
$ mysql -u root -p
> CREATE USER 'wdpress'@'localhost' IDENTIFIED BY '101130150';
> SHOW VARIABLES LIKE 'validate_password%';
> SET GLOBAL validate_password.special_char_count=0;
> ...
```

### SQL 語法
[REF](https://blog.gtwang.org/linux/mysql-create-database-add-user-table-tutorial/)
```
> \q
> ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass'; 
> SHOW DATABASES;
> CREATE DATABASE `wordpress`;
> GRANT ALL PRIVILEGES ON wordpress.* TO 'wdpress'@'localhost';
```

## HTTP Applications
#### Use only one file: index.php
```php
<html>
<body>

<?php
    $uri = $_SERVER['REQUEST_URI'];

    # Display username
    if (strpos($uri, "display")) {
        $str = array_pop(explode('/', $uri));
        echo "Display: $str";
        exit();
    }

    # Calculate A + B
    if (strpos($uri, "calculate")) {
        $str = array_pop(explode('/', $uri));
        $num = explode('+', $str);
        $ans = (int)$num[0] + (int)$num[1];
        echo "Result: $ans";
        exit();
    }
    
    # Redirect to Youtube
    $vid = $_GET['vid'];
    $tim = $_GET['time'];

    if (! $vid) {
        echo "<h2>App route enabled</h2>";
        exit();
    }
    if (! $tim) {
        header("Location: https://youtu.be/$vid");
        exit();
    }

    header("Location: https://youtu.be/$vid?t=$tim");
    exit();
?>

</body>
</html>
```

## Websocked
### Install websockedt
```
$ sudo pkg install websocketd
```
[REF](https://ithelp.ithome.com.tw/questions/10199247)

#### Nginx may eat some paremeter tha ws needed
```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
    
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

#### Start Webosocketd
```
$ websocketd --port=8081 ./ws80
$ websocketd --port=8080 ./ws8080
$ websocketd --ssl --sslcert=/usr/local/www/sahw4/ssl/sa.crt --sslkey=/usr/local/www/sahw4/ssl/sa.key --port=8082 ./ws443
```

## Wordpress
[REF](https://devopscraft.com/how-to-install-wordpress-on-freebsd-12/)
```
$ sudo wget https://wordpress.org/latest.zip
$ sudo unzip latest.zip
$ sudo rm latest.zip
```
[REF](https://kknews.cc/zh-tw/code/6b6jn8q.html)
[REF](http://hk.uwenku.com/question/p-eqcmpumo-bkx.html)

