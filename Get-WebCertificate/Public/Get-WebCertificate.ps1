Function Get-WebCertificate {

    <#

    .SYNOPSIS
    Makes a web request to an HTTPS website and returns the certificate

    .DESCRIPTION
    Makes an HTTPS web request to a given website and port and returns an X509Certificate2 object.
    It will automatically try to connect on TLS1.2, TLS1.1, TLS1.0, SSL3 and SSL2 in that order until it successfully
    connects and pulls the certificate

    .PARAMETER FQDN
    The fully qualified domain name(s) of the web resource you wish to pull a certificate for.

    .PARAMETER Port
    The TCP/IP port that the resource is running on. This has a default of '443' if not specified.

    .EXAMPLE
    PS> Get-WebCertificate -FQDN google.com

    Thumbprint                                Subject
    ----------                                -------
    FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US

    .EXAMPLE
    PS> Get-WebCertificate -FQDN tls-v1-0.badssl.com -Port 1010 -Verbose

    VERBOSE: Trying request using TLS1.2
    VERBOSE: Error pulling certificate using TLS1.2.
    VERBOSE: Trying request using TLS1.1
    VERBOSE: Error pulling certificate using TLS1.1.
    VERBOSE: Trying request using TLS1.0
    VERBOSE: Sucessfully pulled certificate using TLS1.0.

    Thumbprint                                Subject
    ----------                                -------
    CA5308746C1E0644D63AF61BF581C72AF90C7095  CN=*.badssl.com, O=Lucas Garron, L=Walnut Creek, S=California, C=US

    .EXAMPLE
    PS> $Sites = "google.com","microsoft.com","apple.com"
    PS> Get-WebCertificate -FQDN $Sites -Port 443

    Thumbprint                                Subject
    ----------                                -------
    FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
    1E83B66D00F2445EFFA9B2DB51118A46943AA885  CN=*.microsoft.com
    768EE9DAE0D8C91E305FBD0DD738CBF1E92DDBF7  CN=www.apple.com, OU=Internet Services, O=Apple Inc., STREET=1 Infinite Loop, L=Cupertino, S=Ca...


    .EXAMPLE
    PS> "google.com","microsoft.com","apple.com" | Get-WebCertificate -Port 443

    Thumbprint                                Subject
    ----------                                -------
    FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
    1E83B66D00F2445EFFA9B2DB51118A46943AA885  CN=*.microsoft.com
    768EE9DAE0D8C91E305FBD0DD738CBF1E92DDBF7  CN=www.apple.com, OU=Internet Services, O=Apple Inc., STREET=1 Infinite Loop, L=Cupertino, S=Ca...

    #>

    [Cmdletbinding()]
    Param (

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$FQDN,

        [Parameter()]
        [int]$Port = 443

    )

    Begin {

        #Set the information preference so calls to Write-Information appear in the console
        $InformationPreference = "Continue"
        
        #Specify a hash table of protocols. The keys are the friendly names, and the values are the
        #possible values defined for the System.Security.Authentication.SslProtols .NET type
        $AlgorithmTable = [Ordered]@{

            "TLS1.2" = "Tls12"
            "TLS1.1" = "Tls11"
            "TLS1.0" = "Tls"
            "SSL3"   = "Ssl3"
            "SSL2"   = "Ssl2"

        }

        #The number of seconds each attempt to connect for each protocol will last before giving up
        #and moving to the next protocol
        $CertificateRequestTimeout = 2

        #Outputs to the information stream and handles grammar based on the number of inputted $FQDNs
        If ($FQDN.Count -eq 1) {Write-Information "Requesting Certificate, please wait..."}
        If ($FQDN.Count -gt 1) {Write-Information "Requesting Certificates, please wait..."}

    }

    #Loops through each piped in FQDN
    Process {

        #Loops through each site in the FQDN array
        ForEach ($Site in $FQDN) {

            Write-Verbose "Attempting to pull certificate for $Site"

            #Resets the algorithm loop counter to 0
            $AlgorithmLoopCount = 0

            #Loops through each alorithm in the algorithm table. Since the hash table is ordered,
            #this is done in order from top to bottom
            ForEach ($Algorithm in $AlgorithmTable.GetEnumerator()) {

                #Incriment the algorithm loop counter by 1
                $AlgorithmLoopCount++

                Write-Verbose "Trying request using $($Algorithm.Key)"

                #Start a job that requests the certificate. Because the job is a separate PS process,
                #the module must be imported, and various arguments must be passed in.
                $Job = Start-Job -ScriptBlock {
                    
                    Import-Module "$($Args[0])\..\Private\Invoke-WebCertificateRequest.ps1"
                    Invoke-WebCertificateRequest -FQDN $args[1] -Port $args[2] -Algorithm $Args[3].value -ErrorAction SilentlyContinue

                } -ArgumentList $PSScriptRoot, $Site, $Port, $Algorithm

                Write-Verbose "Waiting for up to $CertificateRequestTimeout seconds."
                Wait-Job $Job -Timeout $CertificateRequestTimeout | Out-Null

                #Recieve the job into the certificate variable
                $Certificate = Receive-Job $Job

                #If the certificate is null (no certificate returned)
                If ($Certificate -eq $Null) {
                    
                    #If the current algorithm is the last in the algorithm table
                    If ($AlgorithmLoopCount -eq $AlgorithmTable.Count) {

                        Write-Verbose "No certificate returned. No further protocols to try."
                        Write-Warning "No certificate returned for $Site."
                        #Exit the function
                        Break

                    }

                    Else {
                    
                        Write-Verbose "No certificate returned trying the next protocol."
                        #Loop back up to the next algorithm in the algorithm table
                        Continue

                    }

                }

                #If a certificate is returned
                Else {
                    
                    #Output the certificate object
                    Write-Output $Certificate
                    #Exit the function
                    Break
                
                }

            }

        }

    }

    End {

    }

}