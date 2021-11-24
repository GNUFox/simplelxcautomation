# SimpleLXCSetupAutomation -- SLSA ("Salsa")

This is a set of short scripts to help set up LXCs (when using LXD).
This is somewhat adapted to my needs but feel free to use / customize it.  

## General Idea

* Static network (no DHCP)
* macvlan bridge from containers to real network (have external router for managin network)
* Mostly Debian instances (requires manual config for ubuntu)

## TODOs:
* pass arguments
* host_config.sh
