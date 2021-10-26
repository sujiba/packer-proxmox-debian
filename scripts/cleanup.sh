#!/bin/bash -eux

echo '* Remove ansible'
pip3 uninstall -y ansible


echo '* Cleaning apt-get'
apt-get -y autoremove --purge
apt-get clean

echo '* Cleaning SSH keys'
rm -f /etc/ssh/ssh_host_*

echo "* Remove ssh client directories"
rm -rf /home/*/.ssh
rm -rf /root/.ssh

echo "* Remove temporary files"
rm -rf /tmp/* 
rm -rf /var/tmp/*

echo '* Cleaning all audit logs'
if [ -f /var/log/audit/audit.log ]; then
cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
cat /dev/null > /var/log/lastlog
fi

# /etc/ssh/sshd_config.d/*.conf files are included at the start of the configuration file, 
# so options set there will override those in /etc/ssh/sshd_config.
echo "* Secure ssh login"
sed -i "s/PermitRootLogin yes/#&/i" /etc/ssh/sshd_config
sed -i "s/ChallengeResponseAuthentication no/#&/i" /etc/ssh/sshd_config
sed -i "s/UsePAM yes/#&/i" /etc/ssh/sshd_config
sed -i "s/X11Forwarding yes/#&/i" /etc/ssh/sshd_config

cat > /etc/ssh/sshd_config.d/00-secure-sshd.conf<< EOF
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes

# Allow specific users only - only alice in this case
AllowUsers sujiba

# Sicherheit und Allgemeines
LoginGraceTime 2m
ClientAliveInterval 600
PermitRootLogin no
StrictModes yes
AllowTcpForwarding no
AllowStreamLocalForwarding no
X11Forwarding no

## Ciphers (May 2021)
# Key exchange algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
# Host-key algorithms
HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com
# Encryption algorithms (ciphers)
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
# Message authentication code (MAC) algorithms
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
EOF

echo "* Disable IPv6"
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/90-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/90-disable-ipv6.conf

echo "* Delete and lock root"
passwd -d root
passwd -l root
sed -i "s/PermitRootLogin yes/#&/i" /etc/ssh/sshd_config

echo "* Remove Bash history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history

echo '* Setting hostname to localhost'
cat /dev/null > /etc/hostname
hostnamectl set-hostname localhost

echo '* Cleaning the machine-id'
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

echo '* Zero out the rest of the free space'
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync
