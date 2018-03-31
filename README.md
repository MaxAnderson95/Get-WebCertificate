# Get-WebCertificate
This script makes an HTTPS web request to a given website and port and returns an X509Certificate2 object. It will automatically try to connect on TLS1.2, TLS1.1, TLS1.0, SSL3 and SSL2 in that order until it successfully connects and pulls the certificate.

## Examples
PS> .\Get-WebCertificate.ps1 -FQDN google.com -Port 443

Thumbprint                                Subject
----------                                -------
FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US

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

PS> $Sites = "google.com","microsoft.com","apple.com"
PS> .\Get-WebCertificate.ps1 -FQDN $Sites -Port 443

Thumbprint                                Subject
----------                                -------
FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
1E83B66D00F2445EFFA9B2DB51118A46943AA885  CN=*.microsoft.com
768EE9DAE0D8C91E305FBD0DD738CBF1E92DDBF7  CN=www.apple.com, OU=Internet Services, O=Apple Inc., STREET=1 Infinite Loop, L=Cupertino, S=Ca...

PS> "google.com","microsoft.com","apple.com" | .\Get-WebCertificate.ps1 -Port 443

Thumbprint                                Subject
----------                                -------
FD226574BEC85E043AB2007917B9F636171D485C  CN=*.google.com, O=Google Inc, L=Mountain View, S=California, C=US
1E83B66D00F2445EFFA9B2DB51118A46943AA885  CN=*.microsoft.com
768EE9DAE0D8C91E305FBD0DD738CBF1E92DDBF7  CN=www.apple.com, OU=Internet Services, O=Apple Inc., STREET=1 Infinite Loop, L=Cupertino, S=Ca...
