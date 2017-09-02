#!/bin/bash -e

################### Description ###############################
# basic shell script to create swap space on the hosts
#
################### Verified Platforms ########################
# ubuntu 12.04
# ubuntu 14.04
###############################################################

readonly MAX_FILE_DESCRIPTORS=90000
readonly MAX_WATCHERS=524288
readonly MAX_CONNECTIONS=196608
readonly CONNECTION_TIMEOUT=500
readonly ESTABLISHED_CONNECTION_TIMEOUT=86400

update_descriptor_limits() {
  echo "fs.file-max=90000" | sudo tee -a /etc/sysctl.conf
  echo "*   hard  nofile  90000" | sudo tee -a /etc/security/limits.conf
  echo "*   soft  nofile  90000" | sudo tee -a /etc/security/limits.conf
  echo "*   hard  nproc 90000" | sudo tee -a /etc/security/limits.conf
  echo "*   hard  nproc 90000" | sudo tee -a /etc/security/limits.conf
}

update_watchers() {
  echo 524288 | sudo tee -a /proc/sys/fs/inotify/max_user_watches
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
}

update_network_limits() {
  echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_max=196608" | sudo tee -a /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_generic_timeout=500" | sudo tee -a /etc/sysctl.conf
  echo "net.netfilter.nf_conntrack_tcp_timeout_established=86400" | sudo tee -a /etc/sysctl.conf
}

refresh_settings() {
  sudo sysctl -p
}

main() {
  #sleep 60  #sleep so that we can avoid boot latency errors
  #update_descriptor_limits
  #update_watchers
  #update_network_limits
  #refresh_settings
  pwd
}

main
