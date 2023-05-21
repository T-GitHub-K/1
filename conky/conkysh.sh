#!/bin/bash
sleep 5
conky -b -c /etc/conky/conky.conf &
sleep 1
conky -b -c /etc/conky/conkycal.conf &
