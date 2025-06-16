@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'TerraformParser.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.0'
    
    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'
    
    # Author of this module
    Author = 'PowerShell Developer'
    
    # Company or vendor of this module
    CompanyName = 'Unknown'
    
    # Copyright statement for this module
    Copyright = '(c) 2024. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'A PowerShell module for parsing Terraform HCL code into PowerShell objects'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'ConvertFrom-TerraformString',
        'ConvertFrom-TerraformFile'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Terraform', 'HCL', 'Parser', 'Infrastructure', 'DevOps')
            
            # A URL to the license for this module.
            # LicenseUri = ''
            
            # A URL to the main website for this project.
            # ProjectUri = ''
            
            # A URL to an icon representing this module.
            # IconUri = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of Terraform parser module with support for basic HCL parsing'
        }
    }
}