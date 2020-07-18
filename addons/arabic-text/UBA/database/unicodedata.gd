# The following was taken from CPython code, unsure if available to gdscript otherwise

const db = preload("res://addons/arabic-text/UBA/database/unicode_db.gd")
const index1 = db.index1
const index2 = db.index2
const Database_Records = db.Database_Records
const bidi_names = db.BidirectionalNames

const SHIFT = 7


enum DatabaseRecord {
	bidirectional=2, 
	mirrored=3
	} 

static func bidirectional(ch):
	var code = ch.ord_at(0)
	var index = 0
	if code >= 0x110000:
		index = 0;
	else:
		var sh1 = code>>SHIFT
		index = index1[sh1]
		var n = code&((1<<SHIFT) - 1)
		var sh2 = (index<<SHIFT) + n
		index = index2[sh2]
	
	var record = Database_Records[index]
	var bidi = record[DatabaseRecord.bidirectional]
	var name = bidi_names[bidi];
	return name

static func mirrored(ch):
	var code = ch.ord_at(0)
	var index = 0
	if code >= 0x110000:
		index = 0;
	else:
		index = index1[code>>SHIFT]
		var lsh = index << SHIFT
		var added = code&(1<<SHIFT - 1)
		var i = lsh + added
		index = index2[i]

	return Database_Records[index][DatabaseRecord.mirrored];
