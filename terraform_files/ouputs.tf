output "public_ip_address" {
  value = azurerm_public_ip.terraform_public_ip.ip_address
  description = "Public ip of VM"
}

output "storage_account_name" {
value = azurerm_storage_account.stor_acc_tkxelassign3.name
}

output "storage_container_name" {
value = azurerm_storage_container.tfstate.name
}