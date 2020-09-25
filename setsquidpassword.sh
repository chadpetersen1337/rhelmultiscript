#!/bin/bash

PASSWORD="Elibawnos"

expect << EOF
spawn htpasswd /etc/squid/squid_passwd mikrotik999          
expect { 
    "New password:" { send "$PASSWORD\r"; exp_continue }
    "Re-type new password:" { send "$PASSWORD\r"; exp_continue }    
}                      
EOF
