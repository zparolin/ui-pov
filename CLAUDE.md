# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic research on **Intergenerational Persistence of Poverty (IGPov)** in the United States. The goal is to establish IGPov as a distinct measure that captures welfare consequences at the bottom of the income distribution that Rank-Rank Slopes (RRS) and Intergenerational Elasticity (IGE) do not.

**Primary data source:** PSID (Panel Study of Income Dynamics), supplemented by CPS ASEC for validation.

## Running Stata Do-Files

Execute Stata scripts from the command line:
```bash
"C:\Program Files\Stata19\StataSE-64.exe" -b do "C:\Users\zachary.parolin\Dropbox\_Oxford\Papers\82_IGPovUSA\claude\<filename>.do"
```

Key executable scripts in `/claude`:
- `replicate_igpov.do` - Replicates IGPov estimates by birth cohort
- `explore_data.do` - Data exploration and diagnostics
- `atkinson_mobility.do` - Atkinson-style intergenerational mobility index
- `inequality_aversion_mobility.do` - Inequality aversion mobility (IAM) measure

The master orchestration file is in `/dofiles`: `dofile - 0 - master - USA IGPov.do`

## Directory Structure

```
82_IGPovUSA/
├── claude/              # Active analysis scripts (this directory)
│   ├── dofiles/         # New do-files created by Claude
│   ├── plans/           # Task plans and implementation outlines
│   ├── logs/            # .txt and .log files
│   ├── figures/         # png/ and gph/ subfolders
│   ├── excel/           # Excel output files
│   ├── subdata/         # Intermediate .dta files
│   ├── literature/      # Literature review notes
│   └── paper/           # LaTeX manuscript (synced to Overleaf)
├── dofiles/             # Main analysis pipeline (28 do-files)
├── dofiles for figures/ # Figure generation scripts
├── data/                # PSID and CPS ASEC datasets
│   └── data_ready_usa.dta  # Primary analysis-ready input (3 MB)
└── output/              # Results (figures, tables)
```

## Key Variable Conventions

**Poverty measures:**
- `chpov_opm_SPM`  - Childhood poverty (OPM with SPM adjustment)
- `pov_opm_SPM_2535` - Adult poverty ages 25-35

**Globals defined in `dofile - x - globals.do`:**
- `$covar_basic` - Demographic controls (age, gender, family composition)
- `$covar` - Extended family background (parental employment, education)
- `$medlist` - Mediators (education, employment, family structure)

**Missing data handling:** Binary `miss_*` indicators are created for all analysis variables; missing values are imputed to zero with the indicator included as a control.

## Core Econometric Definitions

- **Childhood Poverty (C):** Ages 0-17
- **Adulthood Poverty (A):** Ages 28-38
- **Relative IGPov:** `Pov_adult = β₁*ChPov + ε`
- **Absolute IGPov:** P(AdulthoodPoverty=1 | ChildhoodPoverty=1)

IGPov decomposes into adult poverty rates and structural dependence (ρ).

## Birth Cohorts
- Analyses should focus on 1960-1988 birth cohorts. When producing graphs and estimates, produce three-year rolling averages by birth cohort to smooth variance.

## Data Requirements

- Use post-tax, post-transfer income (including SNAP, EITC)
- Include non-tax-filers and zero-income households
- Apply longitudinal weights (`weight_ch`, `weight_ch2`) for cohort analyses
- Standard sample restriction: `drop if birthyear >= 1989`

## Path Configuration

Do-files use conditional path detection based on system username:
```stata
global home "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/dofiles"
global data_local "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude"
global output "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude"
```

## Path & Export Conventions

When generating or modifying code, ensure files are saved to these specific directories:

- **Stata Do-Files:** Save new do-files to `/claude/dofiles`.
- **Plans:** Save task plans (.md or .txt) to `/claude/plans`.
- **Log files:** Save .txt logs and Stata .log files to `/claude/logs`.
- **Figures/Images:** Export to `/claude/figures/png` (PNG files) and `/claude/figures/gph` (Stata .gph files).
- **Excel files:** Export to `/claude/excel`.
- **New .dta files made during analyses:** Export to `/claude/subdata`.
- **Literature review notes:** Export to `/claude/literature`.

### Path Configuration in Do-Files
Ensure do-files use these global references for exports:
```stata
global dofiles  "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/dofiles"
global plans    "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/plans"
global logs     "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/logs"
global figures  "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/figures"
global png      "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/figures/png"
global gph      "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/figures/gph"
global excel    "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/claude/excel"
global data     "C:/Users/zachary.parolin/Dropbox/_Oxford/Papers/82_IGPovUSA/data"
```

## Base Folder Organization Rules

**Keep the `/claude` base folder clean.** Only these files should remain in the root:
- `CLAUDE.md` - Project instructions
- `tasks.md` - Research task roadmap
- `data_ready_usa.dta`, `USA_processed.dta` - Primary datasets
- Core do-files: `dofile - 0 - master`, `dofile - 1`, `dofile - 2`, `dofile - x - globals`

**File organization rules:**
1. **Log files (`.log`, `.txt` outputs):** Move to `/claude/logs/`
2. **Temporary do-files (`temp_*.do`, `check_*.do`):** Move to `/claude/subdata/`
3. **New analysis do-files:** Save to `/claude/dofiles/`

**Naming conventions for temporary files:**
- Use `temp_` prefix for exploratory/debugging scripts
- Use `check_` prefix for validation/diagnostic scripts
- These are considered disposable process artifacts

**Periodic cleanup:** When the base folder accumulates temporary files, run:
```bash
mv "path/to/claude"/*.log "path/to/claude/logs/"
mv "path/to/claude"/temp_*.do "path/to/claude/subdata/"
mv "path/to/claude"/check_*.do "path/to/claude/subdata/"
```

## Research Task Roadmap

-Refer to tasks.md for the detailed execution steps and status of each research task.
- When asked to make a plan for a task, provide a step-by-step technical outline, including which variables to use, which do-file to modify, and the specific Stata commands required before executing.

## Stata Coding Standards

**Graph Styling:**
- All figures must use a **white background** and a **minimalist style**.
- **Do NOT include `title()` or `note()` options** in Stata graphs. Titles and notes will be added separately in the manuscript.
- Use the `graph set window fontface "Arial"` command if applicable.
- Prefer `scheme(s1color)` or `scheme(cleanplots)` (if installed) to ensure white backgrounds.
- If no specific scheme is used, always include `plotregion(fcolor(white)) graphregion(fcolor(white))`.
- Export PNG files to `$png` and .gph files to `$gph` (separate subfolders).

## LaTeX & Overleaf Conventions

When adding figures to the manuscript (`/paper/main.tex`), always use the following template:

- **Environment**: Use `\singlespacing` before and `\doublespacing \clearpage` after the figure block.
- **Placement**: Use the `[H]` specifier for exact placement.
- **Width**: Always set `width=\textwidth`.
- **Notes**: Use a `\parbox{14cm}` for the figure notes.

### Figure Template:
\singlespacing
\begin{figure}[H]
    \centering
    \caption{{{TITLE}}}
    \includegraphics[width=\textwidth]{Figures/{{FILE_NAME}}}
    \label{fig:{{LABEL}}}
    \parbox{14cm}{\footnotesize 
    \textit{Note:} {{NOTES}}}
\end{figure}
\doublespacing
\clearpage

**Workflow for Figures:**
1. Generate figure in Stata and export to `$figures/`.
2. If promoted, copy the file to `/paper/Figures/`.
3. Append the template to the relevant section in `main.tex`, populating the title, label, and notes based on the analysis.

## Specialized Workflows

### Overleaf-Sync-Skill (Use for syncing paper updates):
1. **Pull**: `git -C paper pull origin master` (Always pull first to avoid conflicts with web edits).
2. **Stage**: `git -C paper add .`
3. **Commit**: `git -C paper commit -m "Claude Code update: [Short description of figure/text change]"`.
4. **Push**: `git -C paper push origin master`.

**Note**: If a merge conflict occurs during `pull`, pause and ask for manual intervention.

