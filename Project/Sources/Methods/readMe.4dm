//%attributes = {}
/* This method reviews the various uses of this pattern. 

*/

var $class : cs.DemoClass

TRUNCATE TABLE([Table_1])
// instantiate the class with a new record
$class:=cs.DemoClass.new(ds.Table_1.new())

// $class:=cs.DemoClass.new(13)

ASSERT($class.isReady)  //  the class has a entity defined
ASSERT($class.dirty)  // the entity has unsaved changes or is new
ASSERT(Not($class.isEnterable))

// let's make it enterable
$class.isEnterable:=True
ASSERT($class.isEnterable)

$class.name:="Kirk Brooks"
$class.kind:="Developer"
ASSERT($class.save().success)
ASSERT($class.name="Kirk Brooks")

$class.signUp:=Current date-100
$class.updateAddress("state"; "California")
$class.updateAddress("zip"; "94114")
$class.updateAddress("street"; "3725 24th St")
$class.updateAddress("city"; "San Francisco")
var $address : Text
$address:=$class.getAddress()
ASSERT($class.save().success)

$class.signUp:=Current date-200
ASSERT($class.save().success)

$class.updateAddress("street"; "4888 24th St")
ASSERT($class.save().success)

