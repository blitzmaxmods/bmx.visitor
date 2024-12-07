
'	VISITOR
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved
'
'	CHANGE LOG
'	V1.0	07 AUG 21	Initial version
'	V1.1	23 AUG 21	Exception on missing method is optional

' Argument passed to visitor nodes
Type TVisitorArg
	Field node:VNode
	Field indent:String
	
	Method New( node:VNode, indent:String )
		Self.node = node
		Self.indent = indent
	End Method
	
	'Method tab:TVisitorArg()
	'	Self.indent :+ "~t"
	'	Return Self
	'End Method
End Type

' A Visitor is a process that does something with the data
' A Compiler or Interpreter are the usual candidates, but
' you can use them to convert or process data in a natural way

' The Visitor uses reflection to process the Tree
Type TVisitor

	Field exception_on_missing_method:Int = True

	Method visit:String( node:VNode, prefix:String="visit", indent:String="" )
'DebugStop
'		If Not node; Return ""
		If Not node Throw( "Cannot visit null node" ) 
		'If node.name = "" invalid()	' Leave this to use "visit_" method
		
		' Use Reflection to call the visitor method (or an error)
'DebugStop
		Local this:TTypeId = TTypeId.ForObject( Self )
		' The visitor function is either defined in metadata or as node.name
		Local class:String = this.metadata( "class" )
		'If class = "" class = node.name
		Local methd:TMethod = this.FindMethod( prefix+"_"+class )
		If methd
			Local Text:String = String( methd.invoke( Self, [New TVisitorArg(node,indent)] ))
			Return Text
		EndIf
		If exception_on_missing_method ; exception( prefix+"_"+class )
		Return ""
	End Method

	Method visitChildren:String( node:VNode, prefix:String, indent:String="" )
		Local Text:String
		'Local compound:TASTCompound = TASTCmpound( node )
'DebugStop
		If Not node.children; Return ""
		For Local child:VNode = EachIn node.children
			Text :+ visit( child, prefix, indent )
		Next
		Return Text
	End Method
	
	' This is called when node doesn't have metadata or a name...
	Method visit_:String( node:VNode, indent:String="" )
		DebugStop
		'Throw( "Node '"+node.value+"' has no name!" )
	End Method
	
	Method exception( nodename:String )
		Throw( "Method "+nodename+"() does not exist" )
	End Method
	
End Type
