terraform {
  backend "local" {
    # path = "${path.module}/../backend/${var.env}.tfstate" --> does not work, -backend-config is needed
  }
}

# feel free to use any kind of backend