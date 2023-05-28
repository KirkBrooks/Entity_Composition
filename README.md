# Entity_Composition
This is an example of adding class funcitons to a 4D entity through composition: instead of extending the EntityDataClass we pass the entity into the class as a property.

This can be particularly useful refactoring or updating existing code. It doesn't preclude extedning the dataclass but illustrates how you can taylor the class to specific operations involving the entity. For example, let’s say you have a table with a lot of fields - a couple of hunderd perhaps. you need to provide a module to accomplish a specific set of tasks on these records which will involve a few of these fields. You want a developer to be able to implement this module without having to understand how all those fields interact of even mean - you want them to be able to accomplish a task knowing only about the task. 

This is case where this pattern is helpful. You can expose to the user/developer the data in the record they need and the functions they will use. Inside the class you will write the code that manages the details. This allows your class to become a ‘black box’ where the user doesn’t need to know all the details to simply accomplish the tasks they need to do. 

This also makes updating the code much easier. When the steps involved in one of these functions changes you only need to change the code in class - the change doesn’t need to affect the user. When a new functionality is required you add the new functions to return the data required. 

Testing is improved. 

## Constructor

A big problem with implementing ORDA into legacy projects is the Primary Key. The majority of 4D projects have longint primary keys. Many of these projects have UUIDs appended to the tables for journaling but a lot of existing code still expects the legacy ids. The constructor method shows different opitons for locating a given record: 

```4D
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
```

The entity is stored in This._entity. The input can be the UUID, the legacy longint or an instance of the entity itself. This allows you to create a new entity. By default I set the enterable flag to false. The functions I add will respect this flag. 

## State indicators

Working with records I want to know what state the class is in. 

```
Function get isReady : Boolean
	return Bool(This._entity#Null)
	
Function get dirty : Boolean
	return This.isReady && This._entity.touched
	
Function get isEnterable : Boolean
	return Bool(This._enterable)
```

I’m using computed attributes. `isReady` is true when I have an entity defined in the class. `dirty` is true when that entity has been modified without being saved. `isEnterable` is local to the class - the class functions won’t update the entity if this is false. 

These are read-only except for `isEnterable` which as a setter function:

```
Function set isEnterable($enterable : Boolean)
	This._enterable:=Bool($enterable)
```

## Public Functions

4D’s implementation of classes doesn’t enforce the concept of *private* or *protected* properties or functions. These can be approximated but this is only a convention. 

