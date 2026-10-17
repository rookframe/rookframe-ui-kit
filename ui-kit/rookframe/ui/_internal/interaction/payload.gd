extends RefCounted
## Requests contain data, never scene objects or cyclic container references.
static func valid(value: Variant, ancestors: Array = []) -> bool:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY, TYPE_DICTIONARY:
			for ancestor in ancestors:
				if is_same(value, ancestor): return false
			var chain := ancestors.duplicate()
			chain.append(value)
			if value is Dictionary:
				for key in value:
					if not key is String or not valid(value[key], chain): return false
			else:
				for item in value:
					if not valid(item, chain): return false
			return true
	return false
