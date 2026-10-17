# Interaction component contracts

Core scenes inherit native defaults or the host Theme. All slots retain caller-owned
children. A slot getter and its scene-local unique name identify the same node.
Unlisted child paths are private. Input values, validation, actions and domain data
belong to the host. New value setters do not emit user-action signals.

The optional `focus_fallback: Control = null` property on the picker supplies a
stable focus return target. When a focused control disappears, use the next
eligible control at its former position, the preceding control, then the fallback.
Without a valid fallback the host chooses focus. Selection is independent.

Input Group hosts supply exactly one input, minimum 44×44 action targets, and
a unique accessible name for each action. Decorative content stays unfocusable.
The group draws the inherited native Button focus style around the complete group.

## Field and Input Group


**08.1 Field interface**

| Member | Type or signature | Default or result |
| --- | --- | --- |
| `label_text` | String | Empty |
| `help_text` | String | Empty |
| `error_text` | String | Empty |
| `label_visible` | bool | true |
| `get_input_slot()` | Container | The retained input slot |
| `set_target(control)` | Control or null → bool | true after a valid target change |
| `set_error(message)` | String → void | Sets error_text |
| `focus_input()` | → bool | true if an eligible target receives focus |

The target is a native input or a container for a choice group.
A non-null target belongs inside the input slot.
A null target removes the current association.
An invalid target leaves the current association unchanged.

- **FLD-01.** Keep the label, input slot, help, and error in this order.
- **FLD-02.** Hide empty help and error rows.
- **FLD-03.** Show a nonempty error instead of help.
- **FLD-04.** Keep help available in the accessibility description.
- **FLD-05.** Keep the label association when the visible label is hidden.
- **FLD-06.** Keep choice names distinct inside a choice group.
- **FLD-07.** Use the field label as the group name.
- **FLD-08.** Remove old associations when the target changes.
- **FLD-09.** Keep input values and native editor behavior unchanged.
- **FLD-10.** Keep validation rules outside Field.
- **FLD-11.** Keep native read-only selection and copy behavior.
- **FLD-12.** Make focus_input return false when no eligible target exists.

Store the raw error message without the display prefix.
Add the translated error prefix for display and accessibility.

A field for one input supplies that input's accessible name.
A group field supplies the group name and shared description.
The group recipe keeps each choice's own name.

**08.2 Input Group interface**

| Member | Type or signature | Result |
| --- | --- | --- |
| `get_leading_slot()` | → Container | Context before the input |
| `get_input_slot()` | → Container | One input control |
| `get_trailing_slot()` | → Container | Context or actions after the input |

- **IGR-01.** Keep one input control in the input slot.
- **IGR-02.** Let the input use available width.
- **IGR-03.** Keep leading and trailing content at their measured minimum widths.
- **IGR-04.** Keep actions at the minimum target size.
- **IGR-05.** Give every slotted action its own accessible name.
- **IGR-06.** Keep one visible focus perimeter for focus inside the group.
- **IGR-07.** Keep decorative labels and icons outside focus navigation.
- **IGR-08.** Let the host set native disabled and read-only states.
- **IGR-09.** Keep host action availability separate from input availability.
- **IGR-10.** Use Field for the outer label, help, and error.

Supply three examples: a number with units, text with Copy, and search with Clear.
Reuse SearchField for its existing complete search relationship.
A Copy action can remain available for a read-only input.
A Clear action is unavailable when the input cannot change.

**09. Multi-select picker**

**09.1 Interface**

| Member | Type or signature | Default or result |
| --- | --- | --- |
| `set_items(items)` | Array[Dictionary] → bool | true after a valid complete update |
| `set_selected_ids(ids)` | PackedStringArray → bool | true after a valid complete update |
| `get_selected_ids()` | → PackedStringArray | A copy in current record order |
| `selection_changed(ids)` | Signal with PackedStringArray | One accepted user change |
| `show_summary` | bool | true |
| `show_clear` | bool | true |
| `disabled` | bool | false |

| Record key | Type | Default |
| --- | --- | --- |
| `id` | String | Required |
| `title` | String | Required, nonempty |
| `description` | String | Empty |
| `icon` | Texture2D or null | null |
| `disabled` | bool | false |

The initial selection is empty.
This release has no minimum or maximum selection count.
The host can apply domain limits through record availability and external state.
Rich search and Combobox behavior are outside this component.

- **MUL-01.** Use existing choice controls for item rows.
- **MUL-02.** Keep a selected-ID set separate from the focused row.
- **MUL-03.** Reject unknown or duplicate IDs in set_selected_ids.
- **MUL-04.** Remove absent IDs after a valid set_items call.
- **MUL-05.** Keep disabled selected items selected.
- **MUL-06.** Prevent user changes to disabled items.
- **MUL-07.** Permit the host to set a disabled item's selection explicitly.
- **MUL-08.** Let Clear remove all enabled selected items in one action.
- **MUL-09.** Disable Clear when no selected item can be removed.
- **MUL-10.** Give each removable summary item an explicit Remove action.
- **MUL-11.** Disable all picker actions when the picker is disabled.
Keep each record's disabled value unchanged.
- **MUL-12.** Keep focus on the toggled row.
- **MUL-13.** Use the shared focus fallback after a summary action disappears.
- **MUL-14.** Emit no selection_changed signal for external setters or reconciliation.
- **MUL-15.** Return a new array from get_selected_ids.

Apply the complete selection change before the user signal.
Let the host read the reconciled selection after set_items.
Keep input arrays unchanged.
An empty item list shows an empty state and no active Clear action.
Unknown optional record fields do not affect selection behavior.


## Popover, Inspect Card and Toast Stack


**10.1 Popover interface**

Godot supplies popup capture through its native Window and Popup facilities.
Use the [Window reference](https://docs.godotengine.org/en/stable/classes/class_window.html) for engine-specific flags and coordinate rules.

| Member | Type or signature | Result |
| --- | --- | --- |
| `get_content_slot()` | → Container | Retained content |
| `open_for(anchor, initial_focus = null)` | Control, Control or null → bool | true when the popup opens |
| `close(reason = "host")` | StringName → void | Closes an open popup |
| `is_open()` | → bool | Current open state |
| `closed(reason)` | Signal with StringName | One close event per open operation |

Valid close reasons are `host`, `cancel`, `outside`, `anchor_lost`, and `owner_hidden`.
Use `replace` when an open popup changes to another anchor.
A repeated close call has no effect.

- **POP-01.** Reject a missing or invisible anchor.
- **POP-02.** Reject an explicit focus target outside the popup.
- **POP-03.** Reject an explicit focus target that cannot receive focus.
- **POP-04.** Position the popup below the anchor when sufficient space exists.
- **POP-05.** Use the space above when the popup cannot fit below.
- **POP-06.** Otherwise, use the side with more vertical space.
- **POP-07.** Keep the complete popup inside the owner's usable bounds.
- **POP-08.** Use an 8 px gap from the anchor.
- **POP-09.** Use an 8 px margin from usable bounds.
- **POP-10.** Put oversized content inside one scroll owner.
- **POP-11.** Recalculate placement after anchor movement or owner resize.
- **POP-12.** Close the popup when the anchor disappears.
- **POP-13.** Close the popup when its owner becomes hidden.
- **POP-14.** Use native popup capture and outside-dismissal behavior.
- **POP-15.** Keep the Dialog scrim out of this recipe.
- **POP-16.** Consume the dismissal input.
- **POP-17.** Return focus to the anchor when it remains eligible.
- **POP-18.** Otherwise, use the shared focus fallback.
- **POP-19.** Keep content nodes during close and reopen.

If initial_focus is absent, use the first eligible control in content order.
If no eligible control exists, keep cancellation available through the popup.
Use the correct native coordinate system for embedded and separate windows.
Keep host content available through the public slot only.

Use theme constants for the gap and bounds margin.
The values above are their defaults.

**10.2 Inspect Card interface**

| Member | Type or signature | Default or result |
| --- | --- | --- |
| `bind_anchor(control)` | Control → bool | true for a valid anchor |
| `get_preview_slot()` | → Container | Read-only hover content |
| `get_body_slot()` | → Container | Explicit inspection content |
| `get_action_slot()` | → Container | Host-supplied actions |
| `open_inspection()` | → bool | true when explicit inspection opens |
| `close()` | → void | Closes preview or explicit inspection |
| `hover_delay_ms` | int | 500 |
| `hover_close_delay_ms` | int | 150 |

The host supplies preview content and full inspection content.
These are separate presentations.
They are not alternate responsive copies of one editable tree.

- **INS-01.** Open the preview after the hover delay.
- **INS-02.** Keep preview content read-only.
- **INS-03.** Keep the preview outside focus navigation.
- **INS-04.** Keep the preview from capturing keyboard or controller input.
- **INS-05.** Close the preview after the pointer leaves the anchor.
- **INS-06.** Cancel a pending preview when the anchor disappears.
- **INS-07.** Use Popover for explicit inspection.
- **INS-08.** Close the preview before explicit inspection opens.
- **INS-09.** Expose all essential preview information through explicit inspection.
- **INS-10.** Expose actions only in explicit inspection.
- **INS-11.** Keep explicit inspection open until its normal dismissal condition.
- **INS-12.** Prevent hover from reopening a manually closed card until pointer re-entry.
- **INS-13.** Keep item rules and action execution in the host.
- **INS-14.** Keep comparison, pinning, and inspection history outside this release.

Supply a visible Inspect action in the touch example.
Use native activation for the keyboard/controller example.
No dynamic action prompt is required.

**11. Toast stack**

**11.1 Interface**

| Member | Type or signature | Default or result |
| --- | --- | --- |
| `configure_limits(visible, waiting)` | int, int → bool | Defaults: 3 visible; 20 waiting |
| `push(message)` | Dictionary → bool | true when accepted |
| `update_message(id, changes)` | String, Dictionary → bool | true after a valid update |
| `dismiss(id)` | String → bool | true when an accepted message is removed |
| `clear()` | → void | Removes all messages |
| `finished(id, reason, action_id)` | Signal with String, StringName, String | One terminal event per accepted message |
| `timers_paused` | bool | false |

| Message key | Type | Default |
| --- | --- | --- |
| `id` | String | Required, nonempty, unique |
| `title` | String | Required, nonempty |
| `description` | String | Empty |
| `tone` | StringName | `info` |
| `duration_ms` | int | 5000 without an action; 0 with an action |
| `action_id` | String | Empty |
| `action_label` | String | Empty |
| `action_disabled` | bool | false |
| `dismissible` | bool | true |

Valid tones are `info`, `success`, and `error`.
A duration of zero means no timed dismissal.
A positive duration starts when the message becomes visible.
Negative durations are invalid.
Supply both action_id and action_label, or neither.

Valid terminal reasons are `timeout`, `action`, `user`, `host`, and `clear`.
Use an empty action_id except for the action reason.

- **TST-01.** Display accepted messages in arrival order.
- **TST-02.** Promote waiting messages in the same order.
- **TST-03.** Reject a duplicate ID.
- **TST-04.** Reject a new message when both capacities are full.
- **TST-05.** Keep accepted messages unchanged after overflow rejection.
- **TST-06.** Reject a visible limit below one.
- **TST-07.** Reject a waiting limit below zero.
- **TST-08.** Reject limits below the current message counts.
- **TST-09.** Keep a message's queue position during update_message.
- **TST-10.** Keep its elapsed visible time during update_message.
- **TST-11.** Keep message IDs immutable during updates.
- **TST-12.** Pause dismissal while the pointer is over the message.
- **TST-13.** Pause dismissal while focus is inside the message.
- **TST-14.** Pause dismissal while the stack is hidden.
- **TST-15.** Pause dismissal while the application lacks focus.
- **TST-16.** Pause dismissal while timers_paused is true.
- **TST-17.** Keep timer duration independent of game time scale.
- **TST-18.** Obey the host's pause policy for the owning UI branch.
- **TST-19.** Keep focus unchanged when a message appears.
- **TST-20.** Give visible messages a polite native announcement where supported.
- **TST-21.** Announce a message only when it becomes visible.
- **TST-22.** Remove the message before emitting its terminal event.
- **TST-23.** When a message ends normally, emit one terminal event.
- **TST-24.** Cancel timers when the stack exits the scene tree.

The host owns stack placement.
Use Notice for message content where its contract fits.
Use persistent Notice or Dialog for recovery that cannot expire safely.

An action emits finished with reason action.
The host performs the action.
Disabled actions cannot finish the message through activation.
A removed stack emits no delayed terminal events.


Popover also accepts `focus_fallback: Control = null`. Its native Theme constants
`RookframePopover/anchor_gap` and `bounds_margin` default to 8. Preview slots are
read-only; focus and mouse behavior are disabled recursively. Toast Stack uses the
monotonic real-time clock and inherits its UI branch pause policy. Native polite
live regions depend on the platform accessibility backend.
