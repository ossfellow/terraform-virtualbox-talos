# [VirtualBox Networking](https://www.virtualbox.org/manual/ch06.html#networkingmodes)

VirtualBox offers some powerful networking modes, with some unique, and sometimes, peculiar features. This module takes advantage of some of those features to enable automation.

## VirtualBox hostonly network

The [VirtualBox hostonly network](https://www.virtualbox.org/manual/ch06.html#network_hostonly) creates a loopback interface on the host, which is used for network communications between the host, and VirtualBox VMs using the interface.

While it doesn't provide Internet connectivity and cannot be accessed externally (i.e. the local network), it can be combined with a [nat](https://www.virtualbox.org/manual/ch06.html#network_nat) or [bridge](https://www.virtualbox.org/manual/ch06.html#network_bridged) interface, for interesting use cases, like assigning fixed IPs, or querying its DHCP server, for the assigned IP, during the VM boot.

This module creates a VirtualBox hostonly network, and a DHCP server, which is configured by default to provide 65,500 IPs, with a 3 years lease term, for IP stability. While the hostonly network supports both IPv4 and IPv6, its DHCP only supports DHCPv4.

The network and associated DHCP server can be preserved and reused across many VM creation and destruction cycles, but could be torn down and recreated, when requested by the user.

### Useful VirtualBox Commands

- To see the list of all hostonly networks:
  ```
  VBoxManage list hostonlyifs
  ```
- To see the list of all DHCP servers:
  ```
  VBoxManage list dhcpservers
  ```
- To query the hostonly IP of a VM, from the DHCP server:
  ```
  VBoxManage dhcpserver findlease --interface="HOSTONLY-NETWORK" --mac-address="MAC-ADDRESS"
  ```
> Replace _HOSTONLY-NETWORK_ with the name of utilized hostonly network, and _MAC-ADDRESS_ with the MAC address of the second interface (nic2), which you can get from VirtualBox console, or by using the command for [detailed VM information](https://github.com/masoudbahar/terraform-virtualbox-talos//blob/main/modules/vbox-vm/).
