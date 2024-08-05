# Setup visitor service during first boot

systemctl enable visitor --now
firewall-cmd --add-service=visitor --permanent
firewall-cmd --reload
