# Template core for MiSTer

## General description
This core contains the latest version of framework and will be updated when framework is updated. There will be no releases. This core is only for developers. Besides the framework, core demonstrates the basic usage. New or ported cores should use it as a template.

It's highly recommended to follow the notes to keep it standardized for easier maintenance and collaboration with other developers.

## Source structure

### Legend:
* `<core_name>` - you have to use the same name where you see this in this manual. Basically it's your core name.

### Standard MiSTer core should have following folders:
* `sys` - the framework. Basically it's prohibited to change any files in this folder. Framework updates may erase any customization in this folder. All MiSTer cores have to include sys folder as is from this core.
* `rtl` - the actual source of core. It's up to the developer how to organize the inner structure of this folder. Exception is pll folder/files (see below).
* `releases` - the folder where rbf files should be placed. format of each rbf is: <core_name>_YYYYMMDD.rbf (YYYYMMDD is date code of release).

### Other standard files:
* `<core_name>.qpf`- quartus project file. Copy it as is and then modify the line `PROJECT_REVISION = "<core_name>"` according to your core name.
* `<core_name>.qsf` - quartus settings file. In most cases you don't need to modify anything inside (although you may wont to adjust some settings in quartus - this is fine, but keep changes minimal). You also need to watch this file before you make a commit. Quartus in some conditions may "spit" all settings from different files into this file so it will become large. If you see this, then simply revert it to original file.
* `<core_name>.srf` - optional file to disable some warnings which are safe to disable and make message list more clean, so you will have less chance to miss some important warnings. You are free to modify it.
* `<core_name>.sdc` - optional file for constraints in case if core require some special constraints. You are free to modify it.
* `<core_name>.sv` - glue logic between framework and core. This is where you adapt core specific signals to framework.
* `files.qip` - list of all core files. You need to edit it manually to add/remove files. Quartus will use this file but can't edit it. If you add files in Quartus IDE, then they will be added to `<core_name>.qsf` which is recommended manually move them to `files.qip`.
* `clean.bat` - windows batch file to clean the whole project from temporary files. In most cases you don't need to modify it.
* `.gitignore` - list of files should be ignored by git, so temporary files wont be included in commits.
* `jtag.cdf` - it will be produced when you compile the core. By clicking it in Quartus IDE, you will launch programmer where you can send the core to MiSTer over USB blaster cable (see manual for DE10-nano how to connect it). This file normally is not present on cleaned project and not included in commits.

### PLL:
Framework implies use of at least one PLL in the core. Framework doesn't contain this PLL but requires it to be placed in `rtl` folder, so `pll` folder and `pll.v`, `pll.qip` files must be present, however PLL settings are up to the core.

### Verilog Macros

The following macros can be defined and will affect the framework features:

Macro                    |   Effect
-------------------------|---------------------------------
MISTER_DEBUG_NOHDMI      | Disable HDMI-related modules. Speeds up compilation but only analogue/direct video is available
MISTER_DUAL_SDRAM        | Changes configuration of FPGA pins to work with dual SDRAM I/O boards
MISTER_FB                | Allows to use framebuffer from the core
MISTER_SMALL_VBUF        | Sets a smaller video buffer for the ASCAL
MISTER_DOWNSCALE_NN      | Ascal's downscale mode
MISTER_DISABLE_ADAPTIVE  | Disables adaptive scan lines
MISTER_FB_PALETTE        | Framebuffer palette


# Quartus version
Cores must be developed in **Quartus v17.0.x**. It's recommended to have updates, so it will be **v17.0.2**. Newer versions won't give any benefits to FPGA used in MiSTer, however they will introduce incompatibilities in project settings and it will make harder to maintain the core and collaborate with others. **So please stick to good old 17.0.x version.** You may use either Lite or Standard license.


# Automatic builds (Chameleon96)

`.github/workflows/ch96-core.yml` is a reusable GitHub Actions workflow for the
cores that use this repository as the `template` submodule. A core only needs
this file, `.github/workflows/ch96.yml`:

```yaml
name: ch96

on:
  schedule:
    - cron: '41 3 * * *'          # every night (UTC)
  workflow_dispatch:              # Actions > ch96 > Run workflow
  push:
    branches: [master]
    paths-ignore: ['releases/**', '**.md', 'docs/**']

permissions:
  contents: write

jobs:
  ch96:
    uses: teiram/Template_MiSTer_ch96/.github/workflows/ch96-core.yml@master
    with:
      revision: ao486_ch96        # .qsf to compile
      core: ao486                 # -> releases/ao486_YYYYMMDD_ch96.rbf
      # upstream: https://github.com/MiSTer-devel/ao486_MiSTer.git   # optional
      # upstream_branch: master
```

- **Every night**: moves the submodules (`template`, and any other) to the latest
  commit of their branch and, if `upstream` is set, merges it. If something
  changed, it compiles; if it compiles, it commits the new submodule pointers,
  the merge and `releases/<core>_<YYYYMMDD>_ch96.rbf` and pushes them, so the
  Chameleon96 distribution picks the new RBF up. If nothing changed, it does
  nothing.
- **Run workflow** (by hand): the same, but it always compiles.
- **push**: compiles what was pushed and stores the RBF in `releases/`.
- A merge conflict (outside `releases/` and the submodules) or a compilation
  error stops the run before anything is pushed; the run summary shows the
  conflicting files or the Quartus errors, and the timing summary is always
  shown.
- If any clock has negative setup slack (slow model) the RBF is not published
  and the run shows a warning; `require_timing: false` publishes it anyway.
- It compiles with Quartus 17.0 (`raetro/quartus:17.0`) by default
  (`quartus_image` to change it). Lines of the `.qsf` that 17.0 does not
  accept (`TIMING_ANALYZER_MULTICORNER_ANALYSIS`) are removed only for the
  build. There is no public Docker image with 22.1, and 18.1-21.1 cannot be
  used because `sys/` only has PLL files for 13, 17 and 22. Results may differ
  from a local 22.1 build: ao486_ch96 compiles with 17.0 (82 % of the ALMs) but
  its main clock misses setup timing by about 5 ns in the slow model.
- Commits are made by `github-actions[bot]` unless `git_name` / `git_email`
  are given.
