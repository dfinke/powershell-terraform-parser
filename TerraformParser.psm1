# TerraformParser.psm1
# A PowerShell module for parsing Terraform HCL code into PowerShell objects

function ConvertFrom-TerraformString {
    <#
    .SYNOPSIS
    Parses a Terraform HCL string into PowerShell objects.
    
    .DESCRIPTION
    This function takes a Terraform HCL string and converts it into PowerShell objects
    that represent the various Terraform blocks (resource, data, variable, output, provider).
    
    .PARAMETER TerraformContent
    The Terraform HCL content as a string.
    
    .EXAMPLE
    $tf = @'
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
'@
    ConvertFrom-TerraformString -TerraformContent $tf
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string]$TerraformContent
    )
    
    process {
        if ([string]::IsNullOrWhiteSpace($TerraformContent)) {
            return [PSCustomObject]@{
                Resources = @()
                Data = @()
                Variables = @()
                Outputs = @()
                Providers = @()
            }
        }
        
        $result = @{
            Resources = @()
            Data = @()
            Variables = @()
            Outputs = @()
            Providers = @()
        }
        
        # Remove comments and normalize whitespace
        $cleanContent = Remove-TerraformComments -Content $TerraformContent
        
        # Parse different block types
        $result.Resources = Get-TerraformResources -Content $cleanContent
        $result.Data = Get-TerraformData -Content $cleanContent
        $result.Variables = Get-TerraformVariables -Content $cleanContent
        $result.Outputs = Get-TerraformOutputs -Content $cleanContent
        $result.Providers = Get-TerraformProviders -Content $cleanContent
        
        return [PSCustomObject]$result
    }
}

function ConvertFrom-TerraformFile {
    <#
    .SYNOPSIS
    Parses a Terraform HCL file into PowerShell objects.
    
    .DESCRIPTION
    This function reads a Terraform HCL file and converts it into PowerShell objects.
    
    .PARAMETER Path
    The path to the Terraform file to parse.
    
    .EXAMPLE
    ConvertFrom-TerraformFile -Path "main.tf"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }
    
    $content = Get-Content -Path $Path -Raw
    return ConvertFrom-TerraformString -TerraformContent $content
}

function Remove-TerraformComments {
    <#
    .SYNOPSIS
    Removes comments from Terraform content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )
    
    # Remove single-line comments (#)
    $Content = $Content -replace '#[^\r\n]*', ''
    
    # Remove multi-line comments (/* ... */)
    $Content = $Content -replace '/\*[\s\S]*?\*/', ''
    
    # Remove double-slash comments (//)
    $Content = $Content -replace '//[^\r\n]*', ''
    
    return $Content
}

function Get-TerraformResources {
    <#
    .SYNOPSIS
    Extracts resource blocks from Terraform content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )
    
    $resources = @()
    $pattern = 'resource\s+"([^"]+)"\s+"([^"]+)"\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}'
    
    $matches = [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $resource = [PSCustomObject]@{
            Type = $match.Groups[1].Value
            Name = $match.Groups[2].Value
            Configuration = Parse-TerraformBlock -BlockContent $match.Groups[3].Value
        }
        $resources += $resource
    }
    
    return $resources
}

function Get-TerraformData {
    <#
    .SYNOPSIS
    Extracts data blocks from Terraform content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )
    
    $data = @()
    $pattern = 'data\s+"([^"]+)"\s+"([^"]+)"\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}'
    
    $matches = [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $dataBlock = [PSCustomObject]@{
            Type = $match.Groups[1].Value
            Name = $match.Groups[2].Value
            Configuration = Parse-TerraformBlock -BlockContent $match.Groups[3].Value
        }
        $data += $dataBlock
    }
    
    return $data
}

function Get-TerraformVariables {
    <#
    .SYNOPSIS
    Extracts variable blocks from Terraform content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )
    
    $variables = @()
    $pattern = 'variable\s+"([^"]+)"\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}'
    
    $matches = [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $variable = [PSCustomObject]@{
            Name = $match.Groups[1].Value
            Configuration = Parse-TerraformBlock -BlockContent $match.Groups[2].Value
        }
        $variables += $variable
    }
    
    return $variables
}

function Get-TerraformOutputs {
    <#
    .SYNOPSIS
    Extracts output blocks from Terraform content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )
    
    $outputs = @()
    $pattern = 'output\s+"([^"]+)"\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}'
    
    $matches = [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $output = [PSCustomObject]@{
            Name = $match.Groups[1].Value
            Configuration = Parse-TerraformBlock -BlockContent $match.Groups[2].Value
        }
        $outputs += $output
    }
    
    return $outputs
}

function Get-TerraformProviders {
    <#
    .SYNOPSIS
    Extracts provider blocks from Terraform content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )
    
    $providers = @()
    $pattern = 'provider\s+"([^"]+)"\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}'
    
    $matches = [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $provider = [PSCustomObject]@{
            Name = $match.Groups[1].Value
            Configuration = Parse-TerraformBlock -BlockContent $match.Groups[2].Value
        }
        $providers += $provider
    }
    
    return $providers
}

function Parse-TerraformBlock {
    <#
    .SYNOPSIS
    Parses the content inside a Terraform block into key-value pairs.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$BlockContent
    )
    
    $config = @{}
    
    # Split into lines and process each line
    $lines = $BlockContent -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    
    foreach ($line in $lines) {
        # Simple key = value pattern
        if ($line -match '^\s*(\w+)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remove quotes if present
            if ($value -match '^"(.*)"$') {
                $value = $matches[1]
            }
            
            $config[$key] = $value
        }
    }
    
    return $config
}

# Export functions
Export-ModuleMember -Function ConvertFrom-TerraformString, ConvertFrom-TerraformFile