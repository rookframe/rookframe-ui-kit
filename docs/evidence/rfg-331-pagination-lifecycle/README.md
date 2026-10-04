# RFG-331 deferred pagination after removal

Base: public UI Kit `b8aa5fa929f0f352096d63a53f01bf1e0af39b70`. The application diagnostic uses published MÖRK BORG 1.0.123. Publication and consumer pins belong to the coordinating task.

## Cause and resolution

The original native application diagnostic opens the actual phone full sheet, closes its managed surface, then returns to Builder. Before the Builder input, three native `get_viewport_rect` errors originate in `paginated_choices._fit` and `_show_page`. This occurs before Participant teardown. `public123-layers-red.log` preserves that diagnostic; its other assertions pass, while these unexpected native errors correctly keep it red.

The minimized stock Godot loop contains only the public collection scene, an 844 × 390 SubViewport, and an ordinary Button in `get_footer_slot()`. After settling, `remove_child` followed by `queue_free` produces the exact three errors in 0.25 seconds. Actor data, Package services, entries and selection are unnecessary. Removing the footer Button makes the loop green. Its `child_exiting_tree` callback queues a fit while the collection is still in the tree. The deferred callback runs after removal; `is_node_ready()` remains true then.

Ranked hypotheses were shown before probing execution, scheduling, re-entry pending state, and invalid consumer lifecycle. A scheduling-only `is_inside_tree` check still produces all three errors, since scheduling legitimately happens before the collection finishes exiting. The deferred execution guard is therefore necessary.

The fix keeps layout work inside the stock Node lifecycle. `_queue_fit` does not schedule while detached. `_fit` skips detached work and clears its pending flag, allowing later work. `_enter_tree` schedules layout when an already-ready collection is reattached, including new configuration supplied while detached. Initial readiness still schedules through `_ready`. Hidden collections remain in their tree and keep their existing layout behavior. No public API, consumer workflow, selection semantics, or sheet design changes.

## Verification

Stock Godot 4.7.2 Mono. The earlier standalone `--script` runs are diagnostic evidence only: `pagination-green-minimized.log` records the minimized remove/free loop, and `pagination-green-lifecycle.log` records a console counter for four scenarios. That counter is not GdUnit acceptance evidence.

The accepted lifecycle coverage is the later disposable **GdUnit4 6.2.1** suite. `pagination-gdunit-lifecycle.xml` and `pagination-gdunit-lifecycle.log` report **four cases passed in 2.137 seconds**, with zero errors, failures, skips, flaky results or orphans. The cases instantiate the actual public collection scene in stock native SubViewports: phone framed with footer, phone framed without footer, phone ordinary with footer (844 × 390), and desktop framed without footer (1920 × 1080). The suite makes 20 explicit GdUnit assertions, five per case; JUnit reports cases rather than assertion counts. Each case checks:

1. Already-queued layout drains after removal and clears pending state.
2. Detached configuration fits after re-entry, clamps the restored page, retains selected-row visibility/focus, and handles actual native mouse input. Selection emits intent; the consumer projects that ID back through `configure`, as documented.
3. Hidden fitting and resize retain the selected entry and recover focus.
4. Reattachment before a queued callback drains completes fitting and retains focus.
5. Ordinary `remove_child` and `queue_free`, including footer exit, leave no live collection or viewport.

The same suite was run against the original public `b8aa5fa929f0f352096d63a53f01bf1e0af39b70` collection script as a temporary baseline probe. `pagination-gdunit-baseline.xml` and `pagination-gdunit-baseline.log` report four failing cases, 16 errors and exit 100, including the exact native detached `get_viewport_rect` errors. This proves those errors are detected by the framework. The approved `e2a1e807d73c907bf360aa38a21a55b1773965e2` production source was restored byte-for-byte before the passing run. Native runtime and script error reporting were enabled; no expected-error matching, filtering or suppression was used.

The disposable GdUnit acceptance command was:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --path . \
  --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/pagination_lifecycle_disposable.gd -c \
  -rd reports/pagination-lifecycle-gdunit
```

`affected.xml` and `pagination-affected.log` retain the earlier two existing fullscreen-wizard/content cases passed in 0.717 seconds, with zero errors/failures/skips/flaky/orphans. Those cases cover measured choice pagination, profile changes, native field layout and retained content pages; they do not stand in for the four lifecycle cases. GdUnit4 6.2.1 was acquired from its exact public commit through the pinned public gd-plug bootstrap. The disposable lifecycle suite, UID and temporary project settings were removed after saving its reports; no retained test matrix was added. This follow-up changes evidence only: production source and consumer pins remain byte-identical to public `e2a1e807`. The coordinating task owns the original public application rerun after public dependency acquisition.

## Public acquisition pointers

The reviewed upstream SHA must first be pushed to the official UI Kit repository. Consumers select that exact public commit through gd-plug; installed mirrors must not be edited or copied. The host runtime selection is in `rookframe/plug.gd` with `rookframe/rookframe_ui_kit_provenance.json`; fixture project pins/provenance and the expected dependency record in `tools/tests/test_ui_kit_dependency.py` must stay consistent with the host selection. The MÖRK BORG authoring selection is its `plug.gd`, `.rookframe/authoring.lock.json` UI Kit record, and README pin. Install through gd-plug and rerun source/artifact admission and appropriate retained checks before publishing the superseding MÖRK BORG release.

The immutable SDK 0.32.23 supports independently selected UI Kit commits: `rookframe_authoring_checks.py` compares the selected public gd-plug tree when it differs from SDK release metadata. Thus this runtime fix does not require a new SDK domain revision or facade. Host `tools/rookframe_authoring.py` also contains `UI_COMMIT`, used by new-project initialization and `assemble-sdk-authoring-kit.py` release provenance. Changing that authoring default should be coordinated through a new immutable SDK authoring release, rather than editing installed SDK files or rewriting 0.32.23. The static design-system source revision and vendored design authority remain unchanged.
