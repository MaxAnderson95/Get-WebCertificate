Import-Module "$PSScriptRoot\..\Get-WebCertificate" -Force

Describe "Get-WebCertificate" {

    It "Returns an X509Certificate2 object if given a valid FQDN and port" {

        $Error.Clear()
        Remove-Variable Certificate -ErrorAction SilentlyContinue
        $Certificate = Get-WebCertificate -FQDN google.com -Port 443 -Verbose
        $Certificate | Should BeOfType System.Security.Cryptography.X509Certificates.X509Certificate2

    }

    It "Returns an X509Certificate2 object if given a valid FQDN via pipeline and port" {

        $Error.Clear()
        Remove-Variable Certificate -ErrorAction SilentlyContinue
        $Certificate = "google.com" | Get-WebCertificate -Port 443 -Verbose
        $Certificate | Should BeOfType System.Security.Cryptography.X509Certificates.X509Certificate2

    }

    It "Returns an X509Certificate2 object if given a valid FQDN and Port without specifying the parameter names" {

        $Error.Clear()
        Remove-Variable Certificate -ErrorAction SilentlyContinue
        $Certificate = Get-WebCertificate google.com 443 -Verbose
        $Certificate | Should BeOfType System.Security.Cryptography.X509Certificates.X509Certificate2


    }

    It "Returns nothing if given a non valid FQDN" {

        $Error.Clear()
        Remove-Variable Certificate -ErrorAction SilentlyContinue
        $Certificate = Get-WebCertificate -FQDN randomdomainthatdoesnotexistasdf.com -Port 443 -Verbose
        $Certificate | Should Be $Null

    }

    It "Returns nothing if given a valid FQDN but an invalid port" {

        $Error.Clear()
        Remove-Variable Certificate -ErrorAction SilentlyContinue
        $Certificate = Get-WebCertificate -FQDN google.com -Port 1234 -Verbose
        $Certificate | Should Be $Null

    }

    It "Returns one X509Certificate2 object if given 1 valid FQDN and 1 invalid FQDN" {

        $Error.Clear()
        Remove-Variable Certificate -ErrorAction SilentlyContinue
        $Certificate = Get-WebCertificate -FQDN "google.com", "randomdomainthatdoesnotexistasdf.com" -Port 443 -Verbose
        $Certificate.count | Should Be 1
        $Certificate[0] | Should BeOfType System.Security.Cryptography.X509Certificates.X509Certificate2

    }

}