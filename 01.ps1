Describe "Working With Real XML" {
    [xml]$XmlDocument = Get-Content "$PSScriptRoot\01.xml"
    $Content = Get-Content "$PSScriptRoot\01.xml" -Raw

    Context "Try to Set URLs with Regex" {
        $Content = $Content -replace "localhost:8000", "app-dev.contoso.local"
        [xml]$xml = $Content
        it "We don't want to change service addresses" {
            $addresses = $xml.SelectNodes("//service/endpoint") | 
                Foreach-Object { ( $_.Get_Attributes() |
                Where-Object { $_.Get_Name() -eq "address"} ).'#Text' }
            $addresses | Should -match "localhost:8000"
        }
        it "But we do want to change endpoint addresses"{
            $addresses = $xml.SelectNodes("//client/endpoint") | 
                Foreach-Object { ( $_.Get_Attributes() |
                Where-Object { $_.Get_Name() -eq "address"} ).'#Text' }
            $addresses | Should -match "app-dev.contoso.local"
        }
    }

    Context "Setting Client URLs with References" {
        $configuration = $XmlDocument.ChildNodes | ? {$_.Get_Name() -eq "configuration"}
        $servicemodel  = $configuration.ChildNodes | ? {$_.Get_Name() -eq "system.servicemodel"}
        $client        = $servicemodel.ChildNodes | ? {$_.Get_Name() -eq "client"}
        $endpoints     = $client.ChildNodes | ? {$_.Get_Name() -eq "endpoint"}

        foreach ( $endpoint in $endpoints )
        {
            $endpoint.address = $endpoint.address -replace "localhost:8000", "app-dev.contoso.local"
        }

        it "We don't want to change service addresses" {
            $addresses = $XmlDocument.SelectNodes("//service/endpoint") | 
                Foreach-Object { ( $_.Get_Attributes() |
                Where-Object { $_.Get_Name() -eq "address"} ).'#Text' }
            $addresses | Should -match "localhost:8000"
        }
        it "But we do want to change endpoint addresses"{
            $addresses = $XmlDocument.SelectNodes("//client/endpoint") | 
                Foreach-Object { ( $_.Get_Attributes() |
                Where-Object { $_.Get_Name() -eq "address"} ).'#Text' }
            $addresses | Should -match "app-dev.contoso.local"
        }
    }

    Context "Setting Transport Security with XPath" {

        ( $XmlDocument.SelectNodes("//bindings/wsHttpBinding/binding[@name='WSHttpBinding_IHello']/security[@mode]").Attributes | 
            Where-Object {$_.name -eq "Mode"} ).'#Text' = "Transport"

        foreach ( $endpoint in $XmlDocument.SelectNodes("//endpoint") )
        {
            $endpoint.address = $endpoint.address -replace "http:","https:"
        }

        it "We want to change both client and service addresses" {
            $addresses = $XmlDocument.SelectNodes("//endpoint") | 
                Foreach-Object { ( $_.Get_Attributes() |
                Where-Object { $_.Get_Name() -eq "address"} ).'#Text' }
            $addresses | Should -match "https"
        }
        it "And the Binding should have been updated" {
            $XmlDocument.InnerXml | Should -match "Transport"
        }
    }

    $XmlDocument.InnerXml

}