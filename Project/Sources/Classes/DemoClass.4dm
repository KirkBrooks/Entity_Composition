Class constructor($input : Variant)
	// $input could be the entity, legacyId or the PrimaryID
	Case of 
		: (Value type($input)=Is real)
			This._entity:=ds.Table_1.query("LegacyID = :1"; $input).first()
		: (Value type($input)=Is text)
			This._entity:=ds.Table_1.get($input)
		: (Value type($input)=Is object) && (OB Instance of($input; 4D.Entity))
			This._entity:=$input
		Else 
			This._entity:=Null
	End case 
	
	This._enterable:=False
	This._initDetails()
	
	//mark:- computed attributes
Function get isReady : Boolean
	return Bool(This._entity#Null)
	
Function get dirty : Boolean
	return This.isReady && (This._entity.touched() || This._entity.isNew())
	
Function get isEnterable : Boolean
	return Bool(This._enterable)
	
Function set isEnterable($enterable : Boolean)
	This._enterable:=Bool($enterable)
	
Function get name : Text
	return This.isReady ? String(This._entity.name) : ""
	
Function get kind : Text
	return This.isReady ? String(This._entity.kind) : ""
	
Function get signUp : Date
	return This.isReady ? This._entity.signUp : !00-00-00!
	
Function set name($name : Text)
	This._entity.name:=(This.isReady && This.isEnterable) ? $name : This._entity.name
	
Function set kind($kind : Text)
	This._entity.kind:=(This.isReady && This.isEnterable) ? $kind : This._entity.kind
	
Function set signUp($date : Date)
	This._entity.signUp:=(This.isReady && This.isEnterable) ? $date : This._entity.signUp
	
	//mark:- public functions
Function save->$result : Object
	var $isNew : Boolean
	// custom save method
	If (This.isReady)
		$isNew:=This._entity.isNew()
		This._updateModified()
		$result:=This._entity.save()
		
		If ($isNew) && ($result.success)
			This._entity.reload()
		End if 
	End if 
	
Function updateAddress($field : Text; $value : Text)
	var $address : Object
	If (This.isReady) && (This.isEnterable)
		$address:=(This._entity.details.address=Null) ? New object() : This._entity.details.address
		$address[$field]:=$value
		This._entity.details.address:=$address
		This._entity.PrimaryID:=This._entity.PrimaryID  // changing an object field does not 'modify' the record
	End if 
	
Function getAddress->$address : Text
	If (This.isReady) && (This._entity.details.address#Null)
		$address:=This._entity.details.address.street+", " || ""
		$address+=This._entity.details.address.city+", " || ""
		$address+=This._entity.details.address.state+", " || ""
		$address+=This._entity.details.address.zip || ""
	End if 
	
	//mark:- private functions
Function _initDetails
	//  ensure the entity details field is initialized
	If (This.isReady) && (This._entity.details=Null)
		This._entity.details:=New object()
	End if 
	
Function _updateModified
	If (This._entity.details.modified=Null)
		This._entity.details.modified:=New object("user"; ""; "timestamp"; ""; "count"; 0)
	End if 
	
	This._entity.details.modified.user:=Current user
	This._entity.details.modified.timestamp:=Timestamp
	This._entity.details.modified.count+=1
	
	