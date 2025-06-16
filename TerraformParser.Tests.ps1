BeforeAll {
    # Import the module
    $ModulePath = Join-Path $PSScriptRoot "TerraformParser.psd1"
    Import-Module $ModulePath -Force
}

Describe "TerraformParser Module" {
    Context "Module Import" {
        It "Should import the module successfully" {
            Get-Module TerraformParser | Should -Not -BeNullOrEmpty
        }
        
        It "Should export ConvertFrom-TerraformString function" {
            Get-Command ConvertFrom-TerraformString | Should -Not -BeNullOrEmpty
        }
        
        It "Should export ConvertFrom-TerraformFile function" {
            Get-Command ConvertFrom-TerraformFile | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "ConvertFrom-TerraformString" {
        It "Should parse a simple resource block" {
            $terraform = @'
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result | Should -Not -BeNullOrEmpty
            $result.Resources | Should -HaveCount 1
            $result.Resources[0].Type | Should -Be "aws_instance"
            $result.Resources[0].Name | Should -Be "example"
            $result.Resources[0].Configuration.ami | Should -Be "ami-12345678"
            $result.Resources[0].Configuration.instance_type | Should -Be "t2.micro"
        }
        
        It "Should parse multiple resource blocks" {
            $terraform = @'
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "data" {
  bucket = "my-bucket"
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Resources | Should -HaveCount 2
            $result.Resources[0].Type | Should -Be "aws_instance"
            $result.Resources[1].Type | Should -Be "aws_s3_bucket"
        }
        
        It "Should parse a data block" {
            $terraform = @'
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Data | Should -HaveCount 1
            $result.Data[0].Type | Should -Be "aws_ami"
            $result.Data[0].Name | Should -Be "ubuntu"
            $result.Data[0].Configuration.most_recent | Should -Be "true"
        }
        
        It "Should parse a variable block" {
            $terraform = @'
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Variables | Should -HaveCount 1
            $result.Variables[0].Name | Should -Be "instance_type"
            $result.Variables[0].Configuration.description | Should -Be "EC2 instance type"
            $result.Variables[0].Configuration.type | Should -Be "string"
            $result.Variables[0].Configuration.default | Should -Be "t2.micro"
        }
        
        It "Should parse an output block" {
            $terraform = @'
output "instance_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.example.public_ip
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Outputs | Should -HaveCount 1
            $result.Outputs[0].Name | Should -Be "instance_ip"
            $result.Outputs[0].Configuration.description | Should -Be "The public IP of the instance"
        }
        
        It "Should parse a provider block" {
            $terraform = @'
provider "aws" {
  region = "us-west-2"
  profile = "default"
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Providers | Should -HaveCount 1
            $result.Providers[0].Name | Should -Be "aws"
            $result.Providers[0].Configuration.region | Should -Be "us-west-2"
            $result.Providers[0].Configuration.profile | Should -Be "default"
        }
        
        It "Should handle comments in Terraform code" {
            $terraform = @'
# This is a comment
resource "aws_instance" "example" {
  ami           = "ami-12345678"  # Another comment
  instance_type = "t2.micro"
}
/* Multi-line
   comment */
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Resources | Should -HaveCount 1
            $result.Resources[0].Type | Should -Be "aws_instance"
            $result.Resources[0].Name | Should -Be "example"
        }
        
        It "Should parse a complex Terraform configuration" {
            $terraform = @'
provider "aws" {
  region = "us-west-2"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Providers | Should -HaveCount 1
            $result.Variables | Should -HaveCount 1
            $result.Data | Should -HaveCount 1
            $result.Resources | Should -HaveCount 1
            $result.Outputs | Should -HaveCount 1
        }
        
        It "Should handle empty input gracefully" {
            $result = ConvertFrom-TerraformString -TerraformContent ""
            
            $result | Should -Not -BeNullOrEmpty
            $result.Resources | Should -HaveCount 0
            $result.Data | Should -HaveCount 0
            $result.Variables | Should -HaveCount 0
            $result.Outputs | Should -HaveCount 0
            $result.Providers | Should -HaveCount 0
        }
    }
    
    Context "ConvertFrom-TerraformFile" {
        BeforeAll {
            $TestFile = Join-Path $TestDrive "test.tf"
            $TestContent = @'
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
'@
            Set-Content -Path $TestFile -Value $TestContent
        }
        
        It "Should parse a Terraform file successfully" {
            $result = ConvertFrom-TerraformFile -Path $TestFile
            
            $result | Should -Not -BeNullOrEmpty
            $result.Resources | Should -HaveCount 1
            $result.Variables | Should -HaveCount 1
            $result.Resources[0].Type | Should -Be "aws_instance"
            $result.Variables[0].Name | Should -Be "region"
        }
        
        It "Should throw an error for non-existent file" {
            { ConvertFrom-TerraformFile -Path "non-existent.tf" } | Should -Throw "File not found*"
        }
    }
    
    Context "Edge Cases" {
        It "Should handle resource with nested blocks" {
            $terraform = @'
resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Resources | Should -HaveCount 1
            $result.Resources[0].Type | Should -Be "aws_security_group"
            $result.Resources[0].Configuration.name | Should -Be "example"
        }
        
        It "Should handle values without quotes" {
            $terraform = @'
variable "count" {
  type    = number
  default = 5
}
'@
            $result = ConvertFrom-TerraformString -TerraformContent $terraform
            
            $result.Variables | Should -HaveCount 1
            $result.Variables[0].Configuration.type | Should -Be "number"
            $result.Variables[0].Configuration.default | Should -Be "5"
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module TerraformParser -Force -ErrorAction SilentlyContinue
}