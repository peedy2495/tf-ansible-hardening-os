# Playbook is for hardening linux systems.
Refer current supported distributions in top level [README.md](https://github.com/peedy2495/tf-ansible-hardening-os)

This playbook role has been embed in a terraform deployment to test the rollout behaviours in an virtual enviroment, first.
Using terraform, you have to provide a cloud-init template in your virtual environment.

***Recommendation***
This playbook runs a loooong time by using bare ansible.  
Use [anbsible_mitogen](https://github.com/mitogen-hq/mitogen) for fast acceleration, 

## To harden a physical machine, following prerequisites have to be fullifyied:

- offline OS installation
- install via UEFI Secure-Boot
- use minimal installation method
- set static IP/GW manually
- define /boot not less than 1G because of containing multiple kernel/initrd images
- manual partitioning during installation as LVM-Volumes:

| logical volume  | filesystem | mountpoint     | mountoptions                  |recommended size                        |
|-----------------|------------|----------------|-------------------------------|----------------------------------------|
| lv-root         | ext4       | /              | defaults                      | >=80GB                                 |
| lv-home         | ext4       | /home          | relatime,nodev,nosuid,noexec  | ~10GB on servers; rest on desktop inst |
| lv-vartmp       | ext4       | /var/tmp       | relatime,nodev,nosuid,noexec  | >=10GB                                 |
| lv-varlog       | ext4       | /var/log       | relatime,nodev,nosuid,noexec  | >=10GB                                 |
| lv-varlogaudit  | ext4       | /var/log/audit | relatime,nodev,nosuid,noexec  | >=10GB                                 |

  except lv-root set all partitions in fstab with relatim,nodev,nosuid  
  except lv-root and lv-home(?) set all patitions in fstab with noexec
- crypted root and data volumes via LUKS; concider need of setting a grub login at boot (setting in var/main.yml)
- create system-user *ansible* with a homedir in your remote host
- create an ed25519 key pair on local host: `ssh-keygen -o -a 256 -t ed25519 -C "$(hostname)-$(date +'%d-%m-%Y')" -f [Projectpath]/assets/id_ed25519`
  - add content of id_ed25519.pub in /home/ansible/.ssh/authorized_keys on remote host

## How to configure this playbook:

Usage of nexus3 as cached proxy for multi-machine deployments is recommended. All behaviours are configured to use nexus as source.  
Nexus connection parameters are defined in group_vars/all.yml
- associate IP to hostname in your ansible-inventory
- define connection parameters for using nexus in *group_vars/main.yml*  
- used nexus repositories are placed in - modify those related to your nexus repository configurations. By using *nexus: (no/false)* in vars/main.yml, you have only to modyfiy wordlists.yml for internet related urls.
  - vars/main.yml
  - templates/sources.j2
  - vars/wordlists.yml
<br><br>
- define major settings in *var/main.yml*
- define users in *var/user.yml*
  - create salted hash passwords with `mkpasswd -m sha-512` (already set to: `ChangeMe!` )
  - designate a *mail_dest* user in *var/users.yml* for receiving root mails.

## Dependencies:
Following roles will be included:
- [ansible-rootkits](https://github.com/mablanco/ansible-antirootkits)
- [ansible-role-clamav](https://github.com/geerlingguy/ansible-role-clamav)

## Remarks:
Uninstalling linux-modules-extra-[kernelversion] causes boot-stop  
affected:
- ubuntu 20.04 desktop
