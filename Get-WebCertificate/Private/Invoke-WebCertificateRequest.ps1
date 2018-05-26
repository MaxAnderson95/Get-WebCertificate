Function Invoke-WebCertificateRequest {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory=$true)]
        [string]$FQDN,

        [Parameter(Mandatory=$true)]
        [int]$Port = 443,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Tls12","Tls11","Tls","Ssl3","Ssl2")]
        [string]$Algorithm

    )

    $Certificate = $null
    $TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient
    
    try {

        $TcpClient.Connect($FQDN, $Port)
        $TcpStream = $TcpClient.GetStream()

        $Callback = { param($sender, $cert, $chain, $errors) return $true }

        $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)
        
        try {

            $SslStream.AuthenticateAsClient($FQDN, $null, $Algorithm, $true)
            $Certificate = $SslStream.RemoteCertificate

        } finally {
            
            $SslStream.Dispose()
        
        }

    } finally {
        
        $TcpClient.Dispose()
    
    }

    if ($Certificate) {
        
        if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
            
            $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
        
        }

        Write-Output $Certificate
    }
}