# Install visitor package via extra iso.

mkdir /tmp/extra
mount LABEL=EXTRA /tmp/extra

cat <<'EOF' > /etc/yum.repos.d/extra.repo
[extra]
name=extra
baseurl=file:///tmp/extra
enabled=1
EOF

dnf -y install /tmp/extra/visitor*.rpm

rm /etc/yum.repos.d/extra.repo
