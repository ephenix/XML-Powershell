Describe "Basic XML Functionality" {
    
    Context "- Loading XML into PowerShell" {
        
        [xml]$Script:XMLDocument = (Get-Content ".\00.xml")

        it "Start by casting xml content to [xml]. This should give us an XMLDocument object" {
            $XMLDocument.getType().name | Should -Be "XMLDocument"
        }
    
        it "You can reference nodes and attributes alike with .<node name> or .<attribute name>" {
            $XMLDocument.example.node[0].GetType().name | Should -be "XMLElement"
            $XMLDocument.example.node[0].Attribute.getType().name | Should -be "String"
        }
        
        it "You can reference direct child nodes with .ChildNodes" {
            $XMLDocument.ChildNodes.node.count | Should -be 2
        }
    }
    
    Context "- Advanced attribute references" {
            
        it "To get the tag name, nodes without a name attribute or child nodes can be referenced by '.name'" {
            $XMLDocument.ChildNodes.node[0].name | Should -be "node"
        }

        it "To get the tag name on a node with a name attribute or child node, use the get_name() inherited method" {
            $XMLDocument.ChildNodes.namednode.get_name() | Should -be "namednode"
        }

        it "If a node has both an attribute and a subnode that would be referenced, they'll both be returned" {
            $XMLDocument.ChildNodes.namednode.name | Should -be @( "Foo2", "Foo" )
        }

        it "To get just the attribute called name, use .Attributes. The text of this attribute will be in the '#Text' property" {
            $XMLDocument.ChildNodes.namednode.Attributes."#Text" | Should -be "Foo2"
        }

        it "To get just the child node called name, use .ChildNodes" {
            $XMLDocument.ChildNodes.namednode.ChildNodes."#Text" | Should -be "Foo"
        }
    }

    Context "- You can also select nodes by using XPath Lookups" {
        it "The SelectNodes() method works on both XmlDocument or XmlElement objects" {
            #select all nodes of //<type>
            $XMLDocument.SelectNodes("//node").Count | Should -be 2
            $XMLDocument.SelectNodes("//subnode").Count | Should -be 1
            $XMLDocument.SelectNodes("//namednode").Count | Should -be 1

            #select all nodes with the attribute "name"
            $XMLDocument.SelectNodes("//*[@name]").Count | Should -be 1

            #Selecting child nodes from an element
            $XMLDocument.example.node[1].SelectNodes("*").name | Should -be "subnode"
        }
    }
}