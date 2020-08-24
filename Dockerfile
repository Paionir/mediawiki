FROM 	debian:stable

RUN 	apt-get update && apt-get upgrade && \
	apt-get install -y apache2 apt-utils php php-mysql libapache2-mod-php php-xml php-mbstring php-ldap wget curl

RUN	update-ca-certificates && \
	echo -e "TLS_CACERTDIR   /etc/ssl/certs \nTLS_CACERT      /etc/ssl/certs/ca-certificates.crt">> /etc/ldap/ldap.conf 

RUN	cd /tmp && wget -q https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.2.tar.gz && \
	tar -xzf /tmp/mediawiki-1.34.2.tar.gz -C /tmp/ && cd /tmp/mediawiki-1.34.2 && mv ./* /var/www/html && \
	rm -rf /tmp/mediawiki* && rm /var/www/html/index.html

RUN 	curl -S https://extdist.wmflabs.org/dist/extensions/LDAPProvider-REL1_31-8e93a3e.tar.gz -o /tmp/LDAPP.tgz && \
    	tar zxf /tmp/LDAPP.tgz -C /var/www/html/extensions && \
    	rm -rf /tmp/LDAPP.tgz

RUN 	curl -S https://extdist.wmflabs.org/dist/extensions/LDAPAuthorization-REL1_31-53e1ada.tar.gz -o /tmp/LDAPA.tgz && \
    	tar zxf /tmp/LDAPA.tgz -C /var/www/html/extensions && \
    	rm -rf /tmp/LDAPA.tgz

RUN 	curl -S https://extdist.wmflabs.org/dist/extensions/PluggableAuth-REL1_34-17fb1ea.tar.gz -o /tmp/PlugA.tgz && \
    	tar zxf /tmp/PlugA.tgz -C /var/www/html/extensions && \
    	rm -rf /tmp/PlugA.tgz

RUN 	curl -S https://extdist.wmflabs.org/dist/extensions/LDAPAuthentication2-REL1_31-8bd6bc8.tar.gz -o /tmp/LDAPA2.tgz && \
    	tar -zxf /tmp/LDAPA2.tgz -C /var/www/html/extensions && \
    	rm -rf /tmp/LDAPA2.tgz

RUN 	curl -S https://extdist.wmflabs.org/dist/extensions/LDAPUserInfo-REL1_31-da95a07.tar.gz -o /tmp/LDAPU.tgz && \
    	tar zxf /tmp/LDAPU.tgz -C /var/www/html/extensions && \
    	rm -rf /tmp/LDAPU.tgz

RUN	apt-get remove --purge -y wget curl

RUN	apt install -y php7.3-gd php7.3-intl 

RUN	sed -i -e "s/post_max_size = 8M/ post_max_size = 64M/g" /etc/php/7.3/apache2/php.ini && \
	sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 64M/g" /etc/php/7.3/apache2/php.ini

RUN	apt-get autoremove --purge && apt-get remove --purge apt-utilis -y && apt-get clean

EXPOSE	80 	

CMD	["sh", "-c" ,"apachectl start;bash"]







