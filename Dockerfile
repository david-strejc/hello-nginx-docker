FROM openshift/origin-base

RUN yum install -y nginx && echo "Hello World" > /usr/share/nginx/html/index.html && \
    mkdir -p /usr/share/nginx/html/test && echo "Hello World Test" > /usr/share/nginx/html/test/index.html

EXPOSE 8080
EXPOSE 4443


CMD ["/usr/sbin/nginx"]
