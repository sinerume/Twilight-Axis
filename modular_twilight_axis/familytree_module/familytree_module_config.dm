// Point of inclusion for the packaged familytree module.
// Intended include target:
// #include "modular_twilight_axis\familytree_module\familytree_module_config.dm"
//
// Module asset bundled next to this file:
// - relations.dmi
//
// TGUI interface source lives in:
// - tgui\packages\tgui\interfaces\FamilySettingsPanel.tsx

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

#include "familytree_module_helpers.dm"
#include "familytree_heritage.dm"
#include "familytree_family_options.dm"
#include "familytree_subsystem.dm"
