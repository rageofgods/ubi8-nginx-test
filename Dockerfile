FROM registry.access.redhat.com/ubi8:latest

RUN yum -y install nginx

ADD nginx.conf /etc/nginx/conf.d/
ADD index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
