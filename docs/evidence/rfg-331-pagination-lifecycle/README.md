# RFG-331 deferred pagination after removal

Base: public UI Kit `b8aa5fa929f0f352096d63a53f01bf1e0af39b70`. The application diagnostic uses published MÖRK BORG 1.0.123. Publication and consumer pins belong to the coordinating task.

## Cause and resolution

The original native application diagnostic opens the actual phone full sheet, closes its managed surface, then returns to Builder. Before the Builder input, three native `get_viewport_rect` errors originate in `paginated_choices._fit` and `_show_page`. This occurs before Participant teardown. `public123-layers-red.log` preserves that diagnostic; its other assertions pass, while these unexpected native errors correctly keep it red.

The minimized stock Godot loop contains only the public collection scene, an 844 × 390 SubViewport, and an ordinary Button in `get_footer_slot()`. After settling, `remove_child` followed by `queue_free` produces the exact three errors in 0.25 seconds. Actor data, Package services, entries and selection are unnecessary. Removing the footer Button makes the loop green. Its `child_exiting_tree` callback queues a fit while the collection is still in the tree. The deferred callback runs after removal; `is_node_ready()` remains true then.

Ranked hypotheses were shown before probing execution, scheduling, re-entry pending state, and invalid consumer lifecycle. A scheduling-only `is_inside_tree` check still produces all three errors, since scheduling legitimately happens before the collection finishes exiting. The deferred execution guard is therefore necessary.

The fix keeps layout work inside the stock Node lifecycle. `_queue_fit` does not schedule while detached. `_fit` skips detached work and clears its pending flag, allowing later work. `_enter_tree` schedules layout when an already-ready collection is reattached, including new configuration supplied while detached. Initial readiness still schedules through `_ready`. Hidden collections remain in their tree and keep their existing layout behavior. No public API, consumer workflow, selection semantics, or sheet design changes.

## Verification

Stock Godot 4.7.2 Mono. `pagination-green-minimized.log` shows the exact minimized remove/free loop drains without native errors. `pagination-green-lifecycle.log` shows four native scenarios with 20 lifecycle checks in 2.715 seconds: framed collections with/without footer content on phone, ordinary phone collections, and framed desktop collections. They check already-queued removal, pending reset, offline configuration, reattachment after/before callback drain, page clamping, retained selection/focus, native row mouse input, hidden fitting, resize, and ordinary remove/free. Selection continues to emit intent; the consumer projects that selected ID back through `configure`, as documented. No errors are filtered or hidden.

The disposable native command was:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --path . --script tests/pagination_lifecycle_disposable.gd
```

`affected.xml` and `pagination-affected.log`: the two existing fullscreen-wizard/content cases passed in 0.717 seconds, with zero errors/failures/skips/flaky/orphans. The suite includes ordinary measured choice pagination, profile changes, native field layout and retained content pages. GdUnit4 6.2.1 was acquired from its exact public commit through the pinned public gd-plug bootstrap. The temporary fixture, UID and temporary acquisition wiring were removed; no retained test matrix was added. The coordinating task owns the original public application rerun after public dependency acquisition.

## Public acquisition pointers

The reviewed upstream SHA must first be pushed to the official UI Kit repository. Consumers select that exact public commit through gd-plug; installed mirrors must not be edited or copied. The host runtime selection is in `rookframe/plug.gd` with `rookframe/rookframe_ui_kit_provenance.json`; fixture project pins/provenance and the expected dependency record in `tools/tests/test_ui_kit_dependency.py` must stay consistent with the host selection. The MÖRK BORG authoring selection is its `plug.gd`, `.rookframe/authoring.lock.json` UI Kit record, and README pin. Install through gd-plug and rerun source/artifact admission and appropriate retained checks before publishing the superseding MÖRK BORG release.

The immutable SDK 0.32.23 supports independently selected UI Kit commits: `rookframe_authoring_checks.py` compares the selected public gd-plug tree when it differs from SDK release metadata. Thus this runtime fix does not require a new SDK domain revision or facade. Host `tools/rookframe_authoring.py` also contains `UI_COMMIT`, used by new-project initialization and `assemble-sdk-authoring-kit.py` release provenance. Changing that authoring default should be coordinated through a new immutable SDK authoring release, rather than editing installed SDK files or rewriting 0.32.23. The static design-system source revision and vendored design authority remain unchanged.
