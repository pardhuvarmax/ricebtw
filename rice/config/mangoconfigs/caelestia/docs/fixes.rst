Local fixes
===========

This file tracks bugs found and patched locally in this checkout, on top of
the upstream ``evoziosk/caelestia-shell-mango`` fork. Not yet submitted
upstream.

Drawer toggles (launcher, dashboard, session, ...) silently did nothing
------------------------------------------------------------------------

**Symptom**

Keybinds wired to ``caelestia shell drawers toggle <drawer>`` (e.g. the
launcher on ``Super+D``) did nothing. The IPC call returned exit 0 with no
visible error, but no drawer ever opened. ``qs -c caelestia``'s log
(``~/.local/state/quickshell`` / ``$XDG_RUNTIME_DIR/quickshell/by-id/*/log.qslog``)
showed repeated runtime errors on every interaction:

.. code-block:: text

   services/Hypr.qml[75:-1]: TypeError: Property 'map' of object function values() { [native code] } is not a function
   modules/Shortcuts.qml[125:-1]: TypeError: Value is null and could not be converted to an object

Two independent bugs in the MangoWC compatibility layer (``services/Mango.qml``),
introduced by this fork's port from Hyprland, combined to cause this.

**Bug 1 -- ``.values`` used as a property instead of a method call**

``services/Hypr.qml`` re-exports ``Mango.qml``'s ``monitors`` property, which
is a plain JS array (``outputsList: []``). ``workspaces`` and ``toplevels``,
by contrast, are custom objects with a ``.values`` *property* that already
returns an array (a convention carried over from the original Hyprland
service). ``monitorNames()`` assumed the same convention for ``monitors``:

.. code-block:: qml

   // services/Hypr.qml, before
   function monitorNames(): list<string> {
       return monitors.values.map(e => e.name);
   }

On a plain array, ``.values`` (no parens) returns the built-in
``Array.prototype.values`` function reference itself, not an array --
calling ``.map`` on that throws.

*Fix*: ``monitors`` is already the array, so drop ``.values`` entirely:

.. code-block:: qml

   // services/Hypr.qml, after
   function monitorNames(): list<string> {
       return monitors.map(e => e.name);
   }

**Bug 2 -- monitor object identity mismatch breaks per-screen state lookup**

``services/Visibilities.qml`` tracks each drawer's open/closed state in a
``Map`` keyed by monitor object, using **reference equality**:

.. code-block:: qml

   // services/Visibilities.qml (unmodified, upstream-shared code)
   function load(screen: ShellScreen, visibilities: DrawerVisibilities): void {
       screens.set(Hypr.monitorFor(screen), visibilities);
   }

   function getForActive(): DrawerVisibilities {
       return screens.get(Hypr.focusedMonitor);
   }

Before the fix, ``Mango.qml``'s ``monitorFor(screen)`` built and returned a
**brand-new object literal on every call**, while ``focusedMonitor`` was a
separately-cached ``readonly property``. Even though the two objects had
identical field values, they were never the same object, so
``screens.get(Hypr.focusedMonitor)`` could never match what
``screens.set(Hypr.monitorFor(screen), ...)`` had stored. ``getForActive()``
always returned ``undefined``, and ``modules/Shortcuts.qml``'s
``IpcHandler.toggle()`` then did ``visibilities[drawer] = ...`` on that
``undefined`` value -- the ``TypeError`` above.

This fork's ``monitorFor()`` is explicitly single-monitor-only ("MangoWC
doesn't have per-screen monitor info easily accessible via Wayland
protocols"), so there is no real per-screen state to look up anyway -- it
can safely return the one cached ``focusedMonitor`` object instead of
fabricating a new one:

.. code-block:: qml

   // services/Mango.qml, before
   function monitorFor(screen): var {
       return {
           name: focusedOutput,
           id: 0,
           focused: true,
           lastIpcObject: { specialWorkspace: { name: "" } },
           activeWorkspace: focusedWorkspace
       };
   }

.. code-block:: qml

   // services/Mango.qml, after
   readonly property var focusedMonitor: ({
       name: focusedOutput,
       id: 0,
       x: 0,
       y: 0,
       focused: true,
       lastIpcObject: { specialWorkspace: { name: "" } },
       activeWorkspace: focusedWorkspace   // added, was only on the old monitorFor() literal
   })

   function monitorFor(screen): var {
       // Single-monitor-only stub -- return the same cached object as
       // focusedMonitor, not a fresh literal, so Visibilities.qml's
       // identity-keyed Map lookup actually matches.
       return root.focusedMonitor;
   }

``activeWorkspace`` was moved onto ``focusedMonitor`` itself (it wasn't
there before) since ``modules/bar/components/workspaces/Workspaces.qml``
reads ``Hypr.monitorFor(screen).activeWorkspace`` and needed to keep working.

**Files changed**

- ``services/Hypr.qml``
- ``services/Mango.qml``

**Verification**

Rebuilt (``cmake --build build``), reinstalled
(``sudo cmake --install build``), restarted ``qs -c caelestia``, then ran
``caelestia shell drawers toggle launcher`` repeatedly -- no crash, no
``TypeError`` in the log, process stayed alive throughout.

**Status**: submitted upstream as evoziosk/caelestia-shell-mango#3.

``caelestia wallpaper -r`` crashes on MangoWC (not a shell bug -- caelestia-cli itself)
----------------------------------------------------------------------------------------

**Symptom**

``caelestia wallpaper -r <dir>`` (bound to ``Super+Shift+W``) threw a Python
traceback instead of switching the wallpaper:

.. code-block:: text

   File ".../caelestia/utils/hypr.py", line 15, in message
       sock.connect(socket_path)
   FileNotFoundError: [Errno 2] No such file or directory

**Cause**

This isn't the QML shell at all -- ``caelestia-cli`` (a separate upstream
project, installed here from the AUR ``caelestia-cli`` package) was never
ported for MangoWC. ``utils/hypr.py`` hardcodes a socket path built from
``$HYPRLAND_INSTANCE_SIGNATURE``, which doesn't exist outside Hyprland.
``get_wallpapers()`` only hits that path when filtering candidate wallpapers
by monitor resolution:

.. code-block:: python

   def get_wallpapers(args: Namespace) -> list[Path]:
       ...
       if args.no_filter:
           return walls
       monitors = cast(list[dict[str, int]], message("monitors"))  # Hyprland IPC
       ...

**Fix**

No code patch (this lives in a different upstream repo, caelestia-dots/cli,
not evoziosk/caelestia-shell-mango) -- worked around locally by adding
``-n``/``--no-filter`` to the keybind, which skips the Hyprland IPC call
entirely:

.. code-block:: text

   bind=SUPER+SHIFT,w,spawn,caelestia wallpaper -r ~/wallpapers -n

Trade-off: wallpapers are no longer filtered by monitor resolution before
being picked. Not currently considered worth patching caelestia-cli itself
for.

mango keybind edits need a full compositor restart, not just ``reload_config``
--------------------------------------------------------------------------------

After editing ``binds.conf``, running ``mmsg dispatch reload_config`` (or the
``SUPER+CTRL,R`` bind for the same thing) was **not sufficient** for the
caelestia-routed binds to actually fire on keypress -- even though:

- the underlying command worked when run directly (``caelestia shell drawers
  toggle launcher``)
- the exact same spawn worked when triggered manually via
  ``mmsg dispatch "spawn,caelestia shell drawers toggle launcher"``
  (mango's own dispatch mechanism, bypassing the keyboard)
- ``mango -p`` validated the config with no errors
- other, unrelated binds (e.g. ``Super+Return`` -> kitty, ``Super+E`` ->
  thunar) worked fine the whole time, ruling out a global input-capture
  problem

A full mango restart (relogin) resolved it. Root cause not fully pinned down
-- ``reload_config`` may only cover a subset of runtime-tunable settings
(gaps/colors/etc) rather than re-parsing keybind dispatch tables. Worth
knowing before spending time debugging "the command works everywhere except
the actual keypress" -- try a full restart before assuming it's a config or
IPC problem.
