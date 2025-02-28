#!/bin/bash

set -e

brew tap hashicorp/tap
brew install hashicorp/tap/terraform

echo "Terraform version:"
terraform -v

echo "Terraform installation complete"
