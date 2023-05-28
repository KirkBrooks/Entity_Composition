//%attributes = {}
/* Purpose: 
 ------------------
Bug Example ()
 Created by: Kirk as Designer, Created: 05/28/23, 15:03:23
*/

var $entity : cs.Table_1Entity

TRUNCATE TABLE([Table_1])

$entity:=ds.Table_1.new()

$entity.details:=New object("x"; 100)
$entity.name:="name"
$result:=$entity.save()
ASSERT($result.success)
ASSERT($entity.name="name")

//  update the object field and another field
$entity.kind:="save #2"
$entity.details.y:=200
$result:=$entity.save()  //  <== ???

ASSERT($result.success)  //   save success
ASSERT($entity.kind="save #2")  //  field is correct
ASSERT(Num($entity.details.y)=200)  //  object field is correct

ASSERT(Records in table([Table_1])=1)  //  there is only 1 record in the database

$PrimaryID:=$entity.PrimaryID
$entity:=ds.Table_1.get($PrimaryID)  // could be $entity.reload() too
ASSERT($entity.name="name")

/*  here's eveidence the bug - the .save() on line 22 saved the change to 
the field but not the change to the object field. 

If it were a case of the entity not being loaded or changed the actual
field should not have updated. 
*/
ASSERT($entity.kind="save #2")
ASSERT(Num($entity.details.y)=200)

