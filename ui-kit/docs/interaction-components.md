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

