# vim: set expandtab ts=4 sw=4:
# You may add here your
# server {
#	...
# }
# statements for each of your virtual hosts

server {
    listen   80;
    server_name  app.example.com;

    access_log  /var/log/nginx/app-example-com.access.log;

    location / {
        proxy_pass http://127.0.0.1:9090;
        proxy_set_header  X-Real-IP  $remote_addr;
        proxy_read_timeout 700;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

#error_page  404  /404.html;

# redirect server error pages to the static page /50x.html
#
#error_page   500 502 503 504  /50x.html;
#location = /50x.html {
#	root   /var/www/nginx-default;
#}

# deny access to .htaccess files, if Apache's document root
# concurs with nginx's one
#
#location ~ /\.ht {
#deny  all;
#}
}

# HTTPS server
#
#server {
#listen   443;
#server_name  localhost;

#ssl  on;
#ssl_certificate  cert.pem;
#ssl_certificate_key  cert.key;

#ssl_session_timeout  5m;

#ssl_protocols  SSLv2 SSLv3 TLSv1;
#ssl_ciphers  ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
#ssl_prefer_server_ciphers   on;

#location / {
#root   html;
#index  index.html index.htm;
#}
#}
