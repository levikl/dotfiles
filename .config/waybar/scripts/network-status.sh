#!/usr/bin/env bash
# vim: filetype=bash

nmcli -t -f device,connection d | grep -qE wlan.+:.+ && echo "󰖩" || echo "󰤮"
