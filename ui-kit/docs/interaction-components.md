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
`RookframePopover/anchor_gap` and `bounds_margin` default to 8.
`minimum_width` defaults to 320, clamped to the available owner bounds. Preview slots are
read-only; focus and mouse behavior are disabled recursively. Toast Stack uses the
monotonic real-time clock and inherits its UI branch pause policy. Native polite
live regions depend on the platform accessibility backend.

## Collections and transfer


Use Collection, PaginatedChoices, and MiniatureBrowser as the implementation starting points.
Use their existing public paths and methods.
Keep collection behavior independent of host data retrieval.

**12.1 Existing interfaces**

| Interface | Required treatment |
| --- | --- |
| `configure(entries, selected_id, caption, count)` | Keep the existing signature and each component's selection meaning |
| `selected(id)` | Keep the existing user-activation meaning |
| `action_requested(id)` | Keep host action execution separate |
| `capture_state()` | Keep existing serialized keys compatible |
| `restore_state(state)` | Restore view state without changing host selection or domain data |
| `focus_entry(id)` | Reveal the correct page and focus a valid record |
| `get_footer_slot()` | Keep caller-owned content and existing visibility rules |

Collection uses selected to request details.
Its row action requests a separate host action.
Do not replace this behavior with automatic item transfer.

**12.2 Record updates**

- **COL-01.** Match retained rows by stable ID.
- **COL-02.** Keep the row instance when its record changes position.
- **COL-03.** Update changed record fields in the retained row.
- **COL-04.** Free only removed rows.
- **COL-05.** Keep focus on a retained eligible row.
- **COL-06.** Use the shared fallback when the focused row disappears.
- **COL-07.** Keep user selection when a filter temporarily hides its record.
- **COL-08.** Remove selection only when the record leaves the authoritative set.
- **COL-09.** Keep the authoritative set separate from filtered results.
- **COL-10.** Keep text queries in the host or the screen recipe.
- **COL-11.** Keep remote requests outside collection components.
- **COL-12.** Use TaskState for loading, empty, and error content.
- **COL-13.** Keep fake status rows out of the record set.
- **COL-14.** Prevent stale request results from replacing newer data in the host example.

An existing void method keeps its return type.
For invalid records, leave state unchanged and report a developer error.
New methods that reject input use the documented failure result.

**12.3 Page rules**

- **PAG-01.** Keep internal page indexes zero-based.
- **PAG-02.** Display page numbers from one when pages exist.
- **PAG-03.** Disable Previous at the first page.
- **PAG-04.** Disable Next at the last page.
- **PAG-05.** Keep pages inside the current valid range after data removal.
- **PAG-06.** Keep full rows inside each measured page.
- **PAG-07.** Keep the focused row visible after layout changes.
- **PAG-08.** Otherwise, retain the current page when it remains valid.
- **PAG-09.** Keep page changes separate from record activation.
- **PAG-10.** Keep accessible names on page actions.
- **PAG-11.** Keep the current range available without hover.
- **PAG-12.** Keep page restoration silent with respect to user activation.

For new empty summaries, display the translated equivalent of “0 entries.”
Keep existing footer visibility contracts.
PaginatedChoices and Collection have different documented footer rules.
Do not replace those rules with one unconditional hide rule.

**12.4 Required collection examples**

| Example | Required content |
| --- | --- |
| Inventory | Stable IDs, item details, a row action, filtering, pagination, and transfer targets |
| Asset browser | Stable IDs, image previews, filtering, empty/error states, and pagination |
| Basic table | Text, numeric columns, long names, and bounded scrolling |

Use the same shared behavior in both collection examples.
Keep example game rules local to the showcase.
Use 1,000 records for the bounded dataset test.
This is a test size, not a new runtime rejection limit.
Virtualization and advanced Data Table behavior remain outside this release.


**13. Drag-and-drop Slot and Transfer Context**

Use native pointer drag/drop for the pointer route.
Use native focus and activation for the keyboard/controller route.
Use the same validation and transfer request for both routes.
Native activation starts pick-up when a source has no active transfer.
Native activation requests placement when a transfer is active.
Touch uses explicit pick-up and place actions.

**13.1 Drag Slot interface**

| Member | Type | Default |
| --- | --- | --- |
| `slot_id` | String | Empty; required before use |
| `context` | RookframeTransferContext or null | null |
| `can_source` | bool | true |
| `can_target` | bool | true |
| `payload` | Dictionary | Empty |
| `disabled` | Native Button property | false |
| `get_content_slot()` | → Container | Retained host content |

Keep toggle_mode false.
A source slot can contain an item.
An empty target slot can accept a transfer.
The host supplies the payload and visible item data.

Use unique slot IDs inside one context.
A slot registers with its context when it enters the tree.
A slot removes its registration when it exits the tree.
A duplicate slot ID leaves the later slot unavailable.
Report duplicate IDs as developer errors.

**13.2 Transfer Context interface**

Use the public class name `RookframeTransferContext`.
Create one context for each independent host transfer region.
Place it under that region's Control.
Use the nearest Control ancestor as the region.
Keep registered slots in that region and the same Viewport.
Keep the context outside an autoload.

| Member | Type or signature | Default or result |
| --- | --- | --- |
| `placement_validator` | Callable | Empty; placements are unavailable |
| `begin_transfer(source_id)` | String → bool | true when carrying starts |
| `evaluate_target(target_id)` | String → Dictionary | `allowed: bool` and `reason: String` |
| `request_placement(target_id)` | String → int | Positive request ID, or zero on rejection |
| `resolve_transfer(request_id, accepted, error_text = "")` | int, bool, String → bool | false for an unknown or completed request |
| `cancel_transfer(reason = "cancel")` | StringName → bool | true only when carrying ends |
| `get_state()` | → StringName | `idle`, `carrying`, or `pending` |
| `state_changed(state)` | Signal with StringName | One state transition |
| `transfer_requested(request_id, source_id, target_id, payload)` | Signal with int, String, String, Dictionary | One validated placement request |

The validator accepts source_id, target_id, and a payload copy.
It returns a Dictionary with allowed and reason.
The allowed value is a bool.
The reason value is visible host-supplied text.
Require a reason for an unavailable target.
The validator performs no domain or scene mutation.
An invalid validator result makes the target unavailable.
Report invalid validator results as developer errors.
Use a translated unavailable message when no valid reason exists.

Allow null, bool, int, finite float, String, Array, and Dictionary values in a transfer payload.
Require String keys in nested dictionaries.
Reject Node, Resource, Callable, and cyclic payload references.
This restriction makes the request data independent of control lifetime.

**13.3 Transfer states**

| Current state | Event | Next state | Required result |
| --- | --- | --- | --- |
| idle | Valid source activation or pointer drag | carrying | Copy the payload. Display the transfer preview. |
| idle | Invalid source | idle | Return false. Keep data unchanged. |
| carrying | Eligible target focus or pointer movement | carrying | Display current eligibility and reason. |
| carrying | Invalid controller placement | carrying | Show the reason. Emit no request. |
| carrying | Invalid pointer release | idle | Cancel the drag. Emit no request. |
| carrying | Valid placement | pending | Assign a new request ID. Emit one transfer request. |
| carrying | Cancel, source removal, source hiding, or context hiding | idle | Remove the preview. Keep host data unchanged. |
| pending | Duplicate activation | pending | Emit no additional request. |
| pending | Cancel input | pending | Consume the input. Keep the request pending. |
| pending | Host accepts the matching request | idle | Remove pending feedback. Use updated host data. |
| pending | Host rejects; source remains valid | carrying | Show the error. Permit another target. |
| pending | Host rejects; source is absent or unavailable | idle | End the operation. Use focus fallback. |
| Any state | Context destruction | Ended | Remove UI resources. Emit no delayed request. |

Request IDs are unique within one context lifetime.
The host retains the context identity with each request.

A pending request has already crossed into the host.
UI cancellation cannot revoke that request.
The host decides whether an operation can finish after its UI disappears.

**13.4 Transfer rules**

- **DRG-01.** Permit one active transfer per context.
- **DRG-02.** Reject a new transfer while another transfer is active.
- **DRG-03.** Require a visible, enabled source with can_source true.
- **DRG-04.** Require a visible, enabled target with can_target true.
- **DRG-05.** Reject placement on the source slot.
- **DRG-06.** Run the validator again immediately before the request.
- **DRG-07.** Set pending state before emitting transfer_requested.
- **DRG-08.** Increase the positive request ID by one for each new request.
- **DRG-09.** Ignore a result for an old request ID.
- **DRG-10.** Keep the copied payload unchanged during the operation.
- **DRG-11.** Give the host a separate payload copy.
- **DRG-12.** Keep all item movement and inventory changes in the host.
- **DRG-13.** Remove the preview after cancellation.
- **DRG-14.** Suppress source activation after a pointer drag.
- **DRG-15.** Keep the native drop result separate from host acceptance.
- **DRG-16.** Keep pending feedback visible until the matching result.
- **DRG-17.** Give invalid targets text or an icon in addition to color.
- **DRG-18.** Restore focus to the target after acceptance when possible.
- **DRG-19.** Restore focus to the source after cancellation when possible.
- **DRG-20.** Otherwise, use the shared focus fallback.

The host validates the latest domain state before it commits a transfer.
The host applies an accepted transfer once.
The test host demonstrates immediate and delayed results.
A real network protocol is outside this UI component.


Collection and PaginatedChoices add `set_visible_ids(ids: PackedStringArray) -> bool`
and `reset_filter() -> void`. Unknown or duplicate IDs reject the whole filter.
`configure` always receives authoritative records; view filtering never replaces
those records. Both expose `focus_fallback: Control = null`.
MiniatureBrowser adds `focus_entry(id) -> bool`, `capture_state() -> Dictionary`,
and `restore_state(state) -> void`; state holds page and query, never selection.

TransferContext also accepts `focus_fallback: Control = null`. DragSlot's identity
and context are configured before tree entry and remain fixed while registered.
Changing either in-tree reports a developer error and retains the prior value.
Allowed cancellation reasons: cancel, host, source_lost, context_hidden, invalid_drop.
Invalid reasons return false. The context uses native `_unhandled_input`; hosts
handle gameplay after the owning UI region's unhandled cancellation route.
