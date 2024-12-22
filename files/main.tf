terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1gru4gb7a2aevj5s0gr"
  folder_id = "b1gopgrdmsvpblp9civc"
  zone      = "ru-central1-a"
  service_account_key_file = "/home/alex/terraform/key.json"
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "vm" {
  count = 2
  name = "terraform-vm-${count.index + 1}"
  allow_stopping_for_update = true
  resources {
    cores        = 2
    memory       = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd864gbboths76r8gm5f"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

resource "yandex_lb_target_group" "group1" {
  name      = "group1"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = yandex_compute_instance.vm[0].network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = yandex_compute_instance.vm[1].network_interface.0.ip_address
  }
}

resource "yandex_lb_network_load_balancer" "balancer1" {
  name = "balancer1"

  listener {
    name = "my-lb1"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.group1.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}