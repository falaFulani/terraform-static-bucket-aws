provider "aws" {
  #   version = "~> 3.0"
  region  = "us-east-2"
  profile = "wanjiru"
}

#creating a S3 bucket to host static website
resource "aws_s3_bucket" "static_htmls" {

  bucket = "s3-static-test.isobarkenya.com"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "erro.html"
    routing_rules  = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
  tags = {
    Name       = "static_htmls"
    Enviroment = "Dev"
  }
}

#ami-lookup for ubuntu instance 

data "aws_ami" "ubuntu_lookup" {

    most_recent = true 

    filter {
        name = "name"
        values = [
            "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
        ]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
  
}

#nework for the instances


#Provisioning EC2s for internal dev 

#note you need to specify your VPC, subnets, AZs here. right now using the default VPC
resource "aws_instance" "devServer" {
  count         = 2
  ami           = data.aws_ami.ubuntu_lookup.id
  instance_type = "t2.micro"
  key_name      = "devops.pem"

  tags = {
    Name = "DevServer"
  }
}
