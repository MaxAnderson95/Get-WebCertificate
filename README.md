# Get-WebCertificate
This script makes an HTTPS web request to a given website and port and returns an X509Certificate2 object. It will automatically try to connect on TLS1.2, TLS1.1, TLS1.0, SSL3 and SSL2 in that order until it successfully connects and pulls the certificate.

## Examples
```Powershell
PS> .\Get-WebCertificate.ps1 -FQDN google.com -Port 443

Thumbprint                                Subject
----------                                -------
FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
```
```Powershell
PS> .\Get-WebCertificate.ps1 -FQDN tls-v1-0.badssl.com -Port 1010 -Verbose

VERBOSE: Trying request using TLS1.2
VERBOSE: Error pulling certificate using TLS1.2.
VERBOSE: Trying request using TLS1.1
VERBOSE: Error pulling certificate using TLS1.1.
VERBOSE: Trying request using TLS1.0
VERBOSE: Sucessfully pulled certificate using TLS1.0.

Thumbprint                                Subject
----------                                -------
CA5308746C1E0644D63AF61BF581C72AF90C7095  CN=*.badssl.com, O=Lucas Garron, L=Walnut Creek, S=California, C=US
```
```Powershell
PS> $Sites = "google.com","microsoft.com","apple.com"
PS> .\Get-WebCertificate.ps1 -FQDN $Sites -Port 443

Thumbprint                                Subject
----------                                -------
FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
1E83B66D00F2445EFFA9B2DB51118A46943AA885  CN=*.microsoft.com
768EE9DAE0D8C91E305FBD0DD738CBF1E92DDBF7  CN=www.apple.com, OU=Internet Services, O=Apple Inc., STREET=1 Infinite Loop, L=Cupertino, S=Ca...
```
```Powershell
PS> "google.com","microsoft.com","apple.com" | .\Get-WebCertificate.ps1 -Port 443

Thumbprint                                Subject
----------                                -------
FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
1E83B66D00F2445EFFA9B2DB51118A46943AA885  CN=*.microsoft.com
768EE9DAE0D8C91E305FBD0DD738CBF1E92DDBF7  CN=www.apple.com, OU=Internet Services, O=Apple Inc., STREET=1 Infinite Loop, L=Cupertino, S=Ca...
```
```Powershell
PS> $Certificate = .\Get-WebCertificate.ps1 -FQDN google.com -port 443
$Certificate | Fortmat-List *

EnhancedKeyUsageList : {Server Authentication (1.3.6.1.5.5.7.3.1)}
DnsNameList          : {*.google.com, *.android.com, *.appengine.google.com, *.cloud.google.com...}
SendAsTrustedIssuer  : False
Archived             : False
Extensions           : {System.Security.Cryptography.Oid, System.Security.Cryptography.Oid, System.Security.Cryptography.Oid, System.Security.Cryptography.Oid...}
FriendlyName         :
IssuerName           : System.Security.Cryptography.X509Certificates.X500DistinguishedName
NotAfter             : 6/5/2018 2:16:00 PM
NotBefore            : 3/13/2018 2:26:48 PM
HasPrivateKey        : False
PrivateKey           :
PublicKey            : System.Security.Cryptography.X509Certificates.PublicKey
RawData              : {48, 130, 7, 131...}
SerialNumber         : 4C54D11514E579D0
SubjectName          : System.Security.Cryptography.X509Certificates.X500DistinguishedName
SignatureAlgorithm   : System.Security.Cryptography.Oid
Thumbprint           : FD226574BEC85E043AB2007917B9F636171D485C
Version              : 3
Handle               : 3063427817968
Issuer               : CN=Google Internet Authority G2, O=Google Inc, C=US
Subject              : CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
```
