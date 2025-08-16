class_name HandZone

extends BaseZone

@export var base_scale: Vector2 = Vector2(0.60, 0.60)
@export var hover_scale: Vector2 = Vector2(0.90, 0.90)
@export var hover_multiplier: float = 1.4
@export var default_spacing: float = 150.0
@export var margin: float = 60.0
@export var bottom_margin: float = 260.0

@onready var cardHolder: HBoxContainer = $CardHolder
@onready var dropArea: Control = $DropArea
@onready var root_node: Node2D = self

func _ready():
    # make sure hover zoom is not clipped
    cardHolder.clip_contents = false
    _reposition_to_bottom()
    if not get_viewport().size_changed.is_connected(_on_viewport_resized):
        get_viewport().size_changed.connect(_on_viewport_resized)
    arrange_cards()

func add_card(card: Card):
    if card and card not in cards:
        cards.append(card)
        card.reparent(cardHolder)
        card.re_download_image()
        card.size_flags_horizontal = 0
        card.custom_minimum_size = Vector2.ZERO
        card.z_index = 0
        card.z_as_relative = true
        card.set_meta("suppress_hover_clone", true)

        if not card.card_selected.is_connected(_on_card_selected):
            card.card_selected.connect(_on_card_selected)

        if not (card.has_meta("hover_connected") and card.get_meta("hover_connected")):
            card.mouse_entered.connect(func(): _on_card_mouse_entered(card))
            card.mouse_exited.connect(func(): _on_card_mouse_exited(card))
            card.set_meta("hover_connected", true)

        arrange_cards()

func remove_card(card: Card):
    if card in cards:
        cards.erase(card)
        var p := card.get_parent()
        if p:
            p.remove_child(card)
        if card.has_meta("suppress_hover_clone"):
            card.set_meta("suppress_hover_clone", false)
        arrange_cards()

func _get_card_base_size() -> Vector2:
    if cards.is_empty():
        return Vector2(480, 670)
    var c: Card = cards[0]
    var tex: Texture2D = null
    if c.is_front_visible():
        tex = c.front_side.texture
    else:
        tex = c.back_side.texture
    if tex:
        return tex.get_size()
    return Vector2(480, 670)

func arrange_cards() -> void:
    var n := cards.size()
    if n == 0:
        return

    var viewport_width := get_viewport_rect().size.x
    var available := max(0.0, viewport_width - 2.0 * margin)
    var base_size := _get_card_base_size()
    var base_w := base_size.x
    var base_h := base_size.y
    var min_sep := 8.0

    var scale_w := (available - min_sep * max(0, n - 1)) / (n * base_w)
    var target_scale := clamp(scale_w, 0.2, base_scale.x)

    # compute separation so cards fill the row nicely
    var total_cards_w := n * base_w * target_scale
    var sep := 0.0
    if n > 1:
        sep = max(min_sep, floor((available - total_cards_w) / (n - 1)))
    cardHolder.add_theme_constant_override("separation", int(sep))

    # size the holder to full width at bottom
    cardHolder.size = Vector2(viewport_width, bottom_margin)
    dropArea.size = Vector2(viewport_width, bottom_margin)

    for c in cards:
        c.set_meta("normal_scale", target_scale)
        c.scale_card(Vector2(target_scale, target_scale))
        c.custom_minimum_size = Vector2(base_w * target_scale, base_h * target_scale)
        c.z_index = 0
        c.z_as_relative = true

    cardHolder.queue_sort()

func _on_card_mouse_entered(card: Card) -> void:
    var s := card.get_meta("normal_scale") if card.has_meta("normal_scale") else base_scale.x
    var enlarged := max(hover_scale.x, float(s) * hover_multiplier)
    card.scale_card(Vector2(enlarged, enlarged))
    card.z_as_relative = false
    card.z_index = 100

func _on_card_mouse_exited(card: Card) -> void:
    var s := card.get_meta("normal_scale") if card.has_meta("normal_scale") else base_scale.x
    card.scale_card(Vector2(float(s), float(s)))
    card.z_index = 0
    card.z_as_relative = true

func _on_viewport_resized():
    _reposition_to_bottom()
    arrange_cards()

func _reposition_to_bottom() -> void:
    var vp_size := get_viewport_rect().size
    root_node.position.y = vp_size.y - bottom_margin
    # Align holder and drop area at local origin spanning viewport width
    cardHolder.position = Vector2.ZERO
    dropArea.position = Vector2.ZERO

func _on_card_selected(card: Control) -> void:
    print("Card selected:", card)
