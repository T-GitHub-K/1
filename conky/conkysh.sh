#!/bin/bash
sleep 5
conky -b -c /etc/conky/conky.conf &
sleep 5
conky -b -c /etc/conky/conkyncal.conf &
