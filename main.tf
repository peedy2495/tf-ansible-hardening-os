provider "proxmox" {
    pm_api_url = "https://${var.proxmox_host}:8006/api2/json"
    pm_tls_insecure = true

    # Uncomment the below for debugging.
    # pm_log_enable = true
    # pm_log_file = "terraform-plugin-proxmox.log"
    # pm_debug = true
    # pm_log_levels = {
    # _default = "debug"
    # _capturelog = ""
    # }
}

resource "proxmox_vm_qemu" "virtual_machine" {

    name = "ubuntu-2004-hardening"
    target_node = "pve"
    clone = "ubuntu-desktop-2004-cloudinit-template"
    hotplug = 0
    agent = 1
    os_type = "cloud-init"
    cores = 2
    sockets = 1
    #default: host ;use kvm64 in nested virtualization 
    cpu = "kvm64"
    memory = "4096"
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    boot = "c"
    desc = "Hardened Ubuntu LTS 20.04 including more restrictive Users"
    disk {
        slot = 0
        size = "15G"
        type = "scsi"
        storage = "local-lvm"
        iothread = 1
    }
 
    vga {
        type = "cirrus"
        memory = 4
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
        firewall = false
        link_down = false
    }

    network {
        model = "virtio"
        bridge = "vmbr1"
        firewall = false
        link_down = false
    }

    # Not sure exactly what this is for. something about 
    # ignoring network changes during the life of the VM.
    lifecycle {
        ignore_changes = [
        network,
        ]
    }

    # Cloud-init config
    ciuser = "ansible"
    ipconfig0 = "ip=192.168.100.99/24"
    ipconfig1 = "ip=192.168.122.99/24,gw=192.168.122.1"
    sshkeys = file("./assets/id_ed25519.pub")

    provisioner "local-exec" {
        command = "ansible-playbook -u ansible -i inventory hardening.yml"
    }
}