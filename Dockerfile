# Simple static portfolio served by Nginx
FROM nginx:alpine
COPY . /usr/share/nginx/html
# Nginx default serves index.html on :80
