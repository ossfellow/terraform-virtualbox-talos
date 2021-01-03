# [VirtualBox VM](https://www.virtualbox.org/manual/ch08.html#vboxmanage-createvm)

This module is dedicated to creating VirtualBox VMs, using user selected specs and network interface customizations that are suitable for creation of Talos cluster VMs.

However, the module has been generalized to make it portable and useful for other use cases as well, if the installation pause intended for retrieving the hostonly IP address of a VM, which is specifically useful for Talos VMs configuration is ignored.

### Useful VirtualBox Commands

- To see the list of all VMs:
  ```
  VBoxManage list vms
  ```
- To start (boot) a VM:
  ```
  VBoxManage startvm "VM-NAME" --type "STYLE"
  ```
- To see the detailed information about a VM:
  ```
  VBoxManage showvminfo "VM-NAME"
  ```
- To remove the DVD drive, after the OS is installed and VM is up:
  ```
  VBoxManage storageattach "VM-NAME" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium none
  ```
> Replace _VM-NAME_ with the assigned name of VM, and make sure all other attributes are as shown.
> _STYLE_ is one of _gui_, _headless_, or _separated_ values. if _headless_ selected, the VM will run in the background, without VirtualBox console running.
