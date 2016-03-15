export host=\$host;
export proxy_add_x_forwarded_for=\$proxy_add_x_forwarded_for;
echo 'server {

  listen       80;

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    resolver 8.8.8.8;
    proxy_pass http://${HIPPO_PORT_8080_TCP_ADDR}:${HIPPO_PORT_8080_TCP_PORT}/site/;
    proxy_redirect default;
    proxy_cookie_path /site/ /;
  }

}' | envsubst > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'