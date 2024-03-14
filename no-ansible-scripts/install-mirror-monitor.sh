#!/bin/bash


cat  > /etc/xdg/autostart/.desktop << EOF

[Desktop Entry]
Type=Application
Name=custom xrandr
Exec=/usr/local/bin/espejo.sh
Terminal=false

EOF

cat > /usr/local/bin/espejo.sh << EOF
xrandr --output DP-1 --mode 1366x768 --output HDMI-1 --mode 1366x768 --same-as DP-1
EOF

chmod a+x  /usr/local/bin/espejo.sh




