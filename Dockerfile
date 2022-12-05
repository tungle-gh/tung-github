FROM debian:10
LABEL maintainer="xyz@my.bcit.ca"
#COPY index.php /usr/local/apache2/htdocs
#COPY index.php /var/www/html
#RUN apt-get update && apt-get -y install apache2
RUN apt update && apt -y install apt-utils systemd && apt-get -y install libapache2-mod-php
RUN rm /var/www/html/index.html
COPY index.php /var/www/html
COPY tung.jpg /var/www/html
#CMD apachectl -D FOREGROUND
CMD hostname TungA012345678 && apachectl -D FOREGROUND
EXPOSE 80
