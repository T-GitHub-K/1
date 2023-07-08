#!/bin/bash
#sleep 1
conky -b -c /etc/conky/conky.conf &
sleep 1
conky -b -c /etc/conky/conkycal.conf &
#conky -b -c /etc/conky/conkyrc_orange_4k &

