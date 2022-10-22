terraform {
    backend "s3" {
        bucket = "ot.own.terraform.backend"
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}
