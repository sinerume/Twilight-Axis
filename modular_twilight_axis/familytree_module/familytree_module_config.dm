// === FAMILYTREE MODULE ===
// #include "modular_twilight_axis\familytree_module\familytree_module_config.dm"
//
// --- FILE MAP ---
// familytree_vars.dm              - var declarations (preferences, mob, human)
// familytree_prefs.dm             - savefile load/save/sanitize, species lists
// familytree_mob_procs.dm         - MarryTo, verbs, known families, UI toggles
// familytree_royal_job_hooks.dm   - special_check_latejoin for lady/suitor
// familytree_display.dm           - TGUI display panel datum
// familytree_curses.dm            - family_curse datum, status effects
// familytree_member.dm            - family_member: parents/children/spouses, traversal
// familytree_member_terms.dm      - gendered terms (father/mother/son/daughter...)
// familytree_member_relations.dm  - GetRelationshipTo, siblings, cousins, in-laws
// familytree_heritage_core.dm     - heritage datum: house, members, marriage, species calc, UI
// familytree_family_options.dm    - TGUI settings panel backend (ui_data/ui_act)
// familytree_subsystem_compat.dm  - pronouns/species/anatomy compatibility checks
// familytree_subsystem_jobs.dm    - job helpers, age checks, validation
// familytree_subsystem_core.dm    - SSfamilytree: init, signals, lifecycle, queue
// familytree_subsystem_royal.dm   - royal partner jobs, lineage generation
// familytree_subsystem_matching.dm- AssignToHouse/Family/NewlyWed matching
//
// TGUI: tgui/packages/tgui/interfaces/FamilySettingsPanel.tsx
//       tgui/packages/tgui/interfaces/FamilyDisplayPanel.tsx
// Assets: relations.dmi

#ifndef FAMILY_NONE
#define FAMILY_NONE 1
#define FAMILYTREE_MODULE_DEFINED_FAMILY_NONE
#endif

#ifndef FAMILY_PARTIAL
#define FAMILY_PARTIAL 2
#define FAMILYTREE_MODULE_DEFINED_FAMILY_PARTIAL
#endif

#define FAMILY_NEWLYWED 4

#ifndef FAMILY_FULL
#define FAMILY_FULL 3
#define FAMILYTREE_MODULE_DEFINED_FAMILY_FULL
#endif

#define ANY_GENDER 1
#define SAME_GENDER 2
#define DIFFERENT_GENDER 3

#define FAMILY_FATHER "Father"
#define FAMILY_MOTHER "Mother"
#define FAMILY_PROGENY "Progeny"
#define FAMILY_OMMER "Parents Sibling"
#define FAMILY_INLAW "In Law"

#include "familytree_vars.dm"
#include "familytree_prefs.dm"
#include "familytree_mob_procs.dm"
#include "familytree_royal_job_hooks.dm"
#include "familytree_display.dm"
#include "familytree_curses.dm"
#include "familytree_member.dm"
#include "familytree_member_terms.dm"
#include "familytree_member_relations.dm"
#include "familytree_heritage_core.dm"
#include "familytree_family_options.dm"
#include "familytree_subsystem_compat.dm"
#include "familytree_subsystem_jobs.dm"
#include "familytree_subsystem_core.dm"
#include "familytree_subsystem_royal.dm"
#include "familytree_subsystem_matching.dm"
