#!/bin/bash

setup_repos(){
echo "[bahmni]
name            = Bahmni YUM Repository
baseurl         = https://bahmni-repo.twhosted.com/packages/bahmni/
enabled         = 1
gpgcheck        = 0" > /etc/yum.repos.d/bahmni.repo

echo "# Enable to use MySQL 5.6
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/6/x86_64
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql" > /etc/yum.repos.d/mysql56.repo

    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    sudo rpm -Uvh epel-release-latest-6.noarch.rpm
    yum install -y wget
    yum -y update
}

install_oracle_jre(){
    #Optional - Ensure that jre is installed
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jre-7u79-linux-x64.rpm"
    yum localinstall -y jre-7u79-linux-x64.rpm
}

install_mysql(){
    yum install -y mysql-community-server
    service mysqld start
    mysqladmin -u root password password
}

restore_mysql_database(){
    #Optional Step
    rm -rf mysql_backup.sql.gz
    wget https://github.com/Bhamni/emr-functional-tests/blob/master/dbdump/mysql_backup.sql.gz?raw=true -O mysql_backup.sql.gz
    gzip -d mysql_backup.sql.gz
    mysql -uroot -ppassword < mysql_backup.sql
    echo "FLUSH PRIVILEGES" > flush.sql
    mysql -uroot -ppassword < flush.sql
}

install_pgsql(){
    wget http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-7.noarch.rpm
    rpm -ivh pgdg-centos92-9.2-7.noarch.rpm
    yum install -y postgresql92-server
    service postgresql-9.2 initdb
    sed -i 's/peer/trust/g' /var/lib/pgsql/9.2/data/pg_hba.conf
    sed -i 's/ident/trust/g' /var/lib/pgsql/9.2/data/pg_hba.conf
    service postgresql-9.2 start
}

restore_pgsql_db(){
    wget https://github.com/Bhamni/emr-functional-tests/blob/master/dbdump/pgsql_backup.sql.gz?raw=true -O pgsql_backup.sql.gz
    gzip -d pgsql_backup.sql.gz
    psql -Upostgres < pgsql_backup.sql >/dev/null
}

install_bahmni(){
    # need to change it to emr-all
    yum install -y bahmni-emr bahmni-web bahmni-reports bahmni-lab bahmni-erp
}

start_services(){
    service httpd start
    service openmrs start
    service bahmni-lab start
    service openerp start
}


setup_repos
install_oracle_jre
install_mysql
restore_mysql_database
install_pgsql
restore_pgsql_db
install_bahmni
start_services