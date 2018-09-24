Describe "Basic XML Functionality" {
    
    Context "- Loading XML into PowerShell" {
        
        [xml]$Script:XMLDocument = (Get-Content ".\00.xml")

        it "Casting a string to [xml] yields an XMLDocument" {
            $XMLDocument.getType().name | Should -Be "XMLDocument"
        }
    
        it "You can reference nodes and attributes alike with .<node name> or .<attribute name>" {
            $XMLDocument.rootnode.node[0].GetType().name | Should -be "XMLElement"
            $XMLDocument.rootnode.node[0].Attribute.getType().name | Should -be "String"
        }
    }
    
    Context "- Attribute or Node references" {

        it "You can reference direct child nodes with .ChildNodes" {
            $XMLDocument.ChildNodes.count | Should -be 1
            $XMLDocument.rootnode.ChildNodes.count | Should -be 2
        }

        it "To get the tag name, nodes without a name attribute or child nodes can be referenced by '.name'" {
            $XMLDocument.ChildNodes.node[0].name | Should -be "node"
            $XMLDocument.ChildNodes.node[1].name | Should -be "nameattribute"
        }

        it "To get the tag name on a node with a name attribute or child node, use the get_name() inherited method" {
            $XMLDocument.ChildNodes.node[1].get_name() | Should -be "node"
        }

        it "If a node has both an attribute and a subnode that would be referenced, they'll both be returned" {
            $XMLDocument.ChildNodes.node[1].attribute | Should -be @("value2", "value3")
        }

        it "To get just the child node called 'attribute', use .ChildNodes" {
            $XMLDocument.ChildNodes.node[1].ChildNodes."#Text" | Should -be "value3"
        }
    }

    Context "- You can also select nodes by using XPath Lookups" {
        it "The SelectNodes() method works on both XmlDocument or XmlElement objects" {

            #Select all nodes
            $XMLDocument.SelectNodes("//*").count | Should -be 4

            #Selecting child nodes from an element
            $XMLDocument.rootnode.node[1].SelectNodes("*").name | Should -be "attribute"
        }
    }

    Context "- Saving XML" {
        it "The .Save(<Path>) method is the easiest way to save XML to a file" {
            $file = New-TemporaryFile
            { $XMLDocument.Save( $file.FullName ) } | Should -not -Throw

            [xml]$xml2 = Get-Content $file.FullName
            $XMLDocument.SelectNodes("//node").Count | Should -be 2
            Remove-Item $file.FullName
        }
    }
}