terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Paritala"
    storage_account_name = "casestudy3sa"
    container_name       = "casestudy3container"
    key                  = "terraform.tfstate"
  }  
}
provider "azurerm" {
  features {}
  subscription_id = "77a80280-88a5-4f2d-ae33-c108e45bd54f"
  client_id =       "b67a0672-8756-4b98-b0db-552044015d62"
  tenant_id =       "a00090b1-2689-4928-845c-92491870d7ab"
  client_secret =   "G0H8Q~z0HruA0N1FWfFI8nZFqdm69wtT3TZywdbo"
} 


data "azurerm_resource_group" "rg" {
  name = "Paritala"
}

output "id" {
  value = data.azurerm_resource_group.rg.id
}

resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}vn"
  address_space       = ["10.1.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subn" {
  name                 = "${var.prefix}subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${var.prefix}vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "${var.vm-username}" 
  admin_password      = "${var.vm-password}"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

 os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}sa"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_mssql_server" "sql-server" {
  name                         = "${var.prefix}server"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "${var.sql-admin-login}"
  administrator_login_password = "${var.sql-admin-password}"
}

resource "azurerm_mssql_database" "db" {
  name           = "${var.prefix}db"
  server_id      = azurerm_mssql_server.sql-server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false

  tags = {
    foo = "bar"
  }
}