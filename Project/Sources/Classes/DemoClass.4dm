Class constructor($input : Variant)
	// $input could be the entity, legacyId or the PrimaryID
	Case of 
		: (Value type($input)=Is longint)
			This._entity:=ds.Table_1.query("LegacyID = :1"; $input).first()
		: (Value type($input)=Is text)
			This._entity:=ds.Table_1.get($input)
		: (Value type($input)=Is object) && (OB Instance of($input; 4D.Entity))
			This._entity:=$input
		Else 
			This._entity:=Null
	End case 
	
	This._enterable:=False
	
	//mark:- computed attributes
Function get isReady : Boolean
	return Bool(This._entity#Null)
	
Function dirty : Boolean
	return This.isReady && This._entity.touched
	
Function get isEnterable : Boolean
	return Bool(This._enterable)
	
Function get name : Text
	return This.isReady ? String(This._entity.name) : ""
	
Function get kind : Text
	return This.isReady ? String(This._entity.kind) : ""
	
Function get birthDate : Date
	return This.isReady ? This._entity.birthDate : !00-00-00!
	
Function set isEnterable($enterable : Boolean)
	This._enterable:=Bool($enterable)
	
Function set name($name : Text)
	This._entity.name:=(This.isReady && This.isEnterable) ? $name : This._entity.name
	
Function set kind($kind : Text)
	This._entity.kind:=(This.isReady && This.isEnterable) ? $kind : This._entity.kind
	
Function setBirthDate($date : Date)
	This._entity.birthDate:=(This.isReady && This.isEnterable) ? $date : This._entity.birthDate
	
	//mark:- public functions
Function save : Object
	// custom save method
	This._updateModified()
	return This._entity.save()
	
	//mark:- private functions
Function _updateModified
	If (This.isReady)
		If (This._entity.details=Null)
			This._entity.details:=New object()
		End if 
		
		This._entity.details.modified:=New object("user"; Current user; "timestamp"; Timestamp)
	End if 
	