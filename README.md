INSTALL PING MONITOR
~~~
wget --no-check-certificate -N -P /www/httping-monitor/ https://raw.githubusercontent.com/wifikunetworks/httping-monitor/main/httping.sh && chmod +x /www/httping-monitor/httping.sh
~~~

TAMBAHKAN DI STARTUP RC.LOCAL
~~~
(sleep 80 && /www/httping-monitor/httping.sh) &
~~~
