class_name Upgrade extends RefCounted

enum Type { AMMO, WEAPON, GENERAL }
enum Rarity { COMMON, RARE, LEGENDARY }

var uname: String
var logic: String
var level: int
var type: Type
var rarity: Rarity
