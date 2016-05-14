tool
extends EditorScript

func _run():
	var rb=get_scene()
	rb.set_layer_mask(2)
	rb.set_mode(rb.MODE_RIGID)
	rb.get_node("item").connect("body_enter",rb,"_on_item_body_enter")

