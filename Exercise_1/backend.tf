terraform {
    backend "s3" {
        bucket = "ot.terraform.backend"
        key = "terraform.tfstate" 
        region = "us-east-1"
    }
}
