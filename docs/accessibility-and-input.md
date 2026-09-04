# Accessibility, focus, input, and constrained layout

These rules are part of the public behavior contract, not optional catalogue
polish.

## Targets and focus

- Interactive targets are at least 44x44px. The primary task action is normally
  52px high.
- Every keyboard/controller target uses native Godot focus. The Theme renders
  a two-pixel cyan focus perimeter that is distinct from selected or pressed
  state.
- Scene-tree source order is focus order. Responsive components move the same
  retained Controls; they do not create separate wide and compact trees.
- Icon-only Buttons require an `accessibility_name` and a matching tooltip.
- Disabled controls remain readable but do not receive focus or activation.
- A Managed Surface remembers the last valid focus owner in its retained task
  and restores it after minimize/restore when possible.
- `Dialog` and `FilePickerDialog` retain native modal focus. Escape follows the
  same cancellation path as the footer cancel action; acknowledgement dialogs
  intentionally expose only their single confirm action.
- An open `Dialog` inserts one blocking scrim into its Control host. The scrim
  removes background pointer competition while the semantic icon, eyebrow,
  title, and accessibility description communicate the interruption without
  relying on accent color.
- File-picker places, breadcrumbs, file rows, and actions are native focusable
  controls. Places and files use compact icon-left `ItemList` rows. Folder and
  file activation use the native activation signal; the selected filename and
  path remain readable outside the list instead of depending on hover-only
  path tooltips.

## Fields and validation

- A visible field label becomes the native editor accessibility name.
- Help or error copy becomes its accessibility description. Error copy starts
  with the visible word `Error:` and is never color-only.
- Search has one focus perimeter for icon, editor, and clear action. Clearing
  returns focus to the editor. `show_clear_when_empty` keeps that reset action
  discoverable when the route requires it; `clear_minimum_size` preserves its
  target size.
- A complete Choice Row is one target. Supporting description and selected/not
  selected state are included in its accessibility description.

## Status communication

- Notice, TaskState, RollRow, and pending StructuredRow states use a visible
  state word and an icon or shape. Color is supplementary.
- StepProgress uses completion checks, numbered markers, a visible current-step
  summary, and a complete accessibility description instead of appending raw
  implementation-state words to every step label.
- Loading, pending, empty, success, and error remain in the owning task. Do not
  announce state by silently changing a border color.
- Progress bars receive an accessible label. Step progress also communicates
  the current label and current/total position.

## Constrained and long-copy layouts

- Responsive decisions use the component's measured width, not only the OS
  window size.
- `ResponsiveSplit` stacks at 720px by default; `AdaptiveToolbar` at 700px;
  structured rows at 620px; action groups at 560px.
- Labels that can receive Package or localized copy use smart word wrapping.
  Values and short badges may remain intrinsic.
- The primary task owns available space. Secondary status, counts, and action
  lanes have bounded widths and may not squeeze the task into a one-character
  column.
- A Managed Surface has one scroll owner. Header and footer remain fixed and do
  not duplicate actions inside the scrolling body.

## Manual catalogue checks

At 1440x900 and a constrained width, verify:

1. Tab through native Controls, every public component action, and Managed
   Surface chrome in visible source order.
2. Hover and press Buttons; confirm focus, hover, pressed, selected, and
   disabled remain visually distinguishable.
3. Read normal, pending, empty, loading, success, and error examples without
   using color.
4. Inspect the compact StepProgress, ResponsiveSplit, AdaptiveToolbar,
   ActionBar, AdaptiveGrid, RollRow, and StructuredRow profiles.
5. Replace catalogue copy with a long localized sentence and confirm it wraps
   without covering values or actions.
6. Open the native menu, `Dialog`, and `FilePickerDialog`; verify keyboard
   movement, Escape/cancel, initial focus, folder activation, selection, and
   confirmation follow Godot behavior.
