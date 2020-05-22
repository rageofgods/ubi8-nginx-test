FROM rh-registry.dso.techpark.local/rhscl/nginx-116-rhel7 as base

#RUN yum -y install nginx

ADD nginx.conf /etc/nginx/conf.d/
ADD index.html /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
