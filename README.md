# 20250616-133007-TempRepo-For-Agent-Copilot

## TerraformParser PowerShell Module

A PowerShell module for parsing Terraform HCL (HashiCorp Configuration Language) code into PowerShell objects for easier manipulation and analysis.

### Features

- Parse Terraform configuration from strings or files
- Support for all major Terraform block types:
  - `resource` blocks
  - `data` blocks  
  - `variable` blocks
  - `output` blocks
  - `provider` blocks
- Comment removal (single-line `#` and `//`, multi-line `/* */`)
- Robust error handling
- Comprehensive test coverage with Pester

### Installation

```powershell
Import-Module ./TerraformParser.psd1
```

### Usage

#### Parse from String

```powershell
$terraform = @'
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

$result = ConvertFrom-TerraformString -TerraformContent $terraform
```

#### Parse from File

```powershell
$result = ConvertFrom-TerraformFile -Path "main.tf"
```

#### Accessing Parsed Data

```powershell
# Get all resources
$result.Resources

# Get all variables  
$result.Variables

# Get specific resource configuration
$result.Resources[0].Configuration.ami

# Summary counts
Write-Host "Found $($result.Resources.Count) resources"
Write-Host "Found $($result.Variables.Count) variables"
```

### Output Structure

The parser returns a PowerShell object with the following properties:

- `Resources` - Array of resource blocks
- `Data` - Array of data source blocks
- `Variables` - Array of variable blocks
- `Outputs` - Array of output blocks
- `Providers` - Array of provider blocks

Each block contains:
- `Type` - The resource/data source type
- `Name` - The block name
- `Configuration` - Hashtable of key-value pairs from the block

### Testing

Run the Pester tests:

```powershell
Invoke-Pester TerraformParser.Tests.ps1
```

All 16 tests should pass, covering various Terraform configurations and edge cases.