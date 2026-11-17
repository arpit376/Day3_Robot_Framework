# Day 3 Lab Kit: Robot Framework for LTE Testing

Everything you need for the Day 3 labs of *Telecom Testing (4G) Using Python & Robot Framework*
(Module 10). It runs on any laptop or on the lab VM with **no network hardware**: a small
simulated lab stands in for your Day 2 code. On the real VM you swap that one file for your
own Day 2 code (see [Moving to the real lab](#moving-to-the-real-lab)).

## 1. Setup (5 minutes)

You need Python 3.8 or newer.

```bash
cd day3_robot_lab
python3 -m venv .venv && source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python check_setup.py                                     # must print READY
```

On the lab VM the packages are already installed, so only the last command is needed.

## 2. What is in the folder

| Path | What it is | Used in |
|---|---|---|
| `suites/attach.robot` | Attach, detach and reject tests, with suite and test setup and teardown | 3.1, 3.2 |
| `suites/variables_demo.robot` | Global, suite, test and local variable scopes | 3.1 |
| `suites/libraries/standard_libs.robot` | OperatingSystem, String, Collections and Process on an MME log | 3.3 |
| `suites/libraries/provision_api.robot` | Provisioning over REST with RequestsLibrary (starts a local API for you) | 3.3 |
| `suites/keyword_library.robot` | Tests for the library keywords, including KPIs | 3.4 |
| `demos/failing_demo.robot` | Fails on purpose: weak and actionable failure messages | 3.2 |
| `demos/core_check.robot` | SSHLibrary check of a remote core (needs a host, not run by default) | 3.3 |
| `resources/network.resource` | Start Network, Stop Network, Reset UE State, Collect Artefacts | 3.2, 3.3 |
| `resources/procedures.resource` | Provision Default Subscriber, Attach And Verify IP | 3.1, 3.3 |
| `resources/kpi.resource` | Throughput Should Meet Threshold (threshold from data) | 3.4 |
| `libraries/LteLib.py` | **The finished keyword library** (reference solution for Lab 3.4) | 3.4 |
| `libraries/day2_lte.py` | Stand-in for your Day 2 code (simulated lab, with fault injection) | all |
| `env/lab01.py`, `env/lab02.py` | Variable files: one per test bed | 3.1, 3.2 |
| `exercises/MyLteLib_starter.py` | Lab 3.4 starter with TODOs | 3.4 |
| `exercises/my_library_test.robot` | Checks your own library | 3.4 |
| `tools/mock_api.py` | Tiny provisioning API used by the REST lab | 3.3 |
| `data/sample_mme.log` | Sample MME log from Day 2 | 3.3 |
| `lab.args` | Robot argument file (adds `libraries/` to the import path) | all |
| `run.sh` | Shortcuts for every command in this README | all |
| `check_setup.py` | Checks Python and package versions | setup |

Results go to `results/` (one folder per run). Open `report.html` for the summary and `log.html`
for the keyword-by-keyword trace.

## 3. Quick start

```bash
./run.sh first        # runs suites/attach.robot, 4 tests, all pass
```

Open `results/first/report.html` in a browser. `./run.sh` is a thin wrapper; every mode is a
plain command, shown below. On Windows without Git Bash, use the plain commands:
`python -m robot -A lab.args --outputdir results/first suites/attach.robot`.

## 4. Lab 3.2: Your first suites (~55 min)

Goal: explain every line of the report.

**Step 1. Run.** Run the suite and open the report and the log.

```bash
python3 -m robot -A lab.args --outputdir results/first suites/attach.robot
```

Questions: Which keyword runs once per file? Which runs before every test? Where did the
`artefacts/lab.log` link in the log come from? (Hint: Test Teardown.)

**Step 2. Override a variable from the command line.**

```bash
python3 -m robot -A lab.args --variable ENB_HOST:10.9.9.9 --outputdir results/override suites/variables_demo.robot
```

In `log.html`, open "Global And Suite Variables Are Visible". It now logs `10.9.9.9`, not
`10.0.0.12` from `env/lab01.py`. Try a second variable file:
`--variablefile env/lab02.py`.

**Step 3. Select by tag.**

```bash
python3 -m robot -A lab.args --include smoke --outputdir results/smoke suites
python3 -m robot -A lab.args --include negative --outputdir results/negative suites
python3 -m robot -A lab.args --exclude long --outputdir results/full suites
```

Count the tests in each run. Which tag marks a requirement? (`REQ-ATTACH-01` and so on.)
Open the report, scroll to *Test Statistics by Tag*.

**Step 4. Break it.** Two ways, use both:

```bash
# a) a fault in the network: attach works but no IP is allocated
LAB_FAULT=no_ip python3 -m robot -A lab.args --include attach --outputdir results/fault suites/attach.robot
# b) two tests that fail on purpose, with a weak and an actionable message
python3 -m robot -A lab.args --outputdir results/failing demos/failing_demo.robot
```

Windows (PowerShell) for (a): `$env:LAB_FAULT="no_ip"` first, then the robot command.
Open `log.html`, follow the red keyword to the cause, and compare the two messages from (b).
Rewrite the weak one. Other faults: `LAB_FAULT=slow` and `LAB_FAULT=core_down`.

## 5. Lab 3.3: The library ecosystem

```bash
python3 -m robot -A lab.args --outputdir results/libs  suites/libraries/standard_libs.robot
python3 -m robot -A lab.args --outputdir results/api   suites/libraries/provision_api.robot
```

* `standard_libs.robot` reads `data/sample_mme.log` with OperatingSystem, String and
  Collections and starts a program with Process.
* `provision_api.robot` starts `tools/mock_api.py` itself and uses `POST On Session`.
  Try changing the second test to expect `201` and read the failure.
* `demos/core_check.robot` needs a reachable host with systemd and an SSH key, so it is not
  run by default. If you have one:

```bash
python3 -m robot -A lab.args --variable CORE_HOST:<host> --variable KEY_FILE:<path-to-key> \
    --outputdir results/ssh demos/core_check.robot
```

Compare it with the paramiko code you wrote on Day 2.

## 6. Lab 3.4: Your own keyword library (~70 min)

Goal: Day 3 tests call *your* keywords instead of raw commands.

1. Read `libraries/day2_lte.py` (your Day 2 functions) and the target interface on slide 29:
   Provision Subscriber, Start eNodeB, Attach UE, Get Attach Result, Measure Throughput.
2. Copy the starter and fill in the TODOs:

   ```bash
   cp exercises/MyLteLib_starter.py libraries/MyLteLib.py
   python3 -m robot -A lab.args --outputdir results/mine exercises/my_library_test.robot
   ```

   The test file is red until the TODOs are done and green when your library works.
3. Check your library against the four rules (slide 31): one job, return data, time-bounded,
   explains itself.
4. Compare with the finished `libraries/LteLib.py`, then run the full keyword suite:

   ```bash
   python3 -m robot -A lab.args --outputdir results/library suites/keyword_library.robot
   ```

   One line in the console reads `[ ERROR ] cause=8 status=REJECTED`. That is expected: the test
   "Failed Attach Explains Itself" provokes a rejected attach to prove the failure message and
   the log context are good.

## 7. Cheat sheet

| I want to | Command |
|---|---|
| Run everything safe | `python3 -m robot -A lab.args suites` |
| Run one file | `python3 -m robot -A lab.args suites/attach.robot` |
| Select by tag | `--include smoke` / `--exclude long` |
| Override a variable | `--variable NAME:value` |
| Keep runs apart | `--outputdir results/run42` |
| Check syntax without running | `--dryrun` |
| Run a single test | `--test "UE Attaches And Gets An IP Address"` |
| Log level for more detail | `--loglevel DEBUG` |

Remember: **two or more spaces** separate a keyword from its arguments.

## Moving to the real lab

`libraries/day2_lte.py` is the only file that talks to the (simulated) network. Replace the
function bodies with your Day 2 code and keep these names and the `AttachResult` fields
(`imsi`, `status`, `cause`, `ip`, `setup_ms`):

`start_core`, `start_enb`, `stop_all`, `reset_ue_state`, `provision_subscriber`, `attach`,
`detach`, `bearer_exists`, `measure_throughput`, `tail`, `save_logs`.

Nothing else changes: the suites, resource files and `LteLib.py` keep working. Put real
hosts and keys in a new `env/` file for your test bed, and select it with
`--variablefile env/<yourfile>.py`.

## Troubleshooting

| Problem | Fix |
|---|---|
| `No keyword with name 'Attach UE' found` | Run with `-A lab.args` so `libraries/` is on the import path |
| `Importing library 'LteLib' failed` | Run robot from inside the `day3_robot_lab` folder |
| `ModuleNotFoundError: RequestsLibrary` | `pip install robotframework-requests` |
| Keyword and arguments run together | Use at least two spaces between them |
| Port 8099 already in use | Stop the old `mock_api.py`, or change `API_URL` and the port |
| A test passes alone but fails in a run | Shared state: reset in Test Setup, as `attach.robot` does |
| `LAB_FAULT` still active | Unset it: `unset LAB_FAULT` (Windows: `Remove-Item Env:LAB_FAULT`) |
