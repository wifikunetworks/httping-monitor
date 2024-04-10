INSTALL PING MONITOR
~~~
wget --no-check-certificate -N -P /www/ping-monitor/ https://raw.githubusercontent.com/wifikunetworks/ping-monitor/main/ping.sh && chmod +x /www/ping-monitor/ping.sh
~~~

TAMBAHKAN DI STARTUP RC.LOCAL
~~~
(sleep 80 && /www/ping-monitor/ping.sh) &
~~~
