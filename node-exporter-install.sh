#! /bin/sh

workdir=/tmp/

function adduser(){
    groupadd -r node-exp
    useradd -g node-exp -s /sbin/nologin node-exp
}

function install(){
    cd $workdir
    tar xzf node_exporter-0.18.1.linux-amd64.tar.gz
    mv /tmp/node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
    #add to systemd service
    cat > /etc/systemd/system/node_exporter.service << EOF
    [Service]
    Type=simple
    User=node-exp
    Group=node-exp
    ExecStart=/usr/local/bin/node_exporter \
        --collector.systemd \
        --collector.textfile \
        --web.listen-address=0.0.0.0:9100
    SyslogIdentifier=node_exporter
    Restart=always
    PrivateTmp=yes
    ProtectHome=yes
    NoNewPrivileges=yes
    ProtectSystem=full
    [Install]
    WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    if [ "$?" -eq 0 ];then
        systemctl start node_exporter
        systemctl enable node_exporter
    else
        exit1
    fi
}

ps aux |grep 'node_exporter'| grep -v grep

if [ "$?" -eq 0 ];then
    echo "installed"
    exit 1
    else
        id node-exp
        if [ "$?" -eq 0 ];then
            install
        else
            adduser
            install
	fi
fi
