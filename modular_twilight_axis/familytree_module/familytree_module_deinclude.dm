// Undef point for familytree module macros.
// Intended include target after the module's compile section:
// #include "modular_twilight_axis\familytree_module\familytree_module_deinclude.dm"

#ifdef FAMILYTREE_MODULE_DEFINED_FAMILY_NONE
#undef FAMILY_NONE
#undef FAMILYTREE_MODULE_DEFINED_FAMILY_NONE
#endif

#ifdef FAMILYTREE_MODULE_DEFINED_FAMILY_PARTIAL
#undef FAMILY_PARTIAL
#undef FAMILYTREE_MODULE_DEFINED_FAMILY_PARTIAL
#endif

#undef FAMILY_NEWLYWED

#ifdef FAMILYTREE_MODULE_DEFINED_FAMILY_FULL
#undef FAMILY_FULL
#undef FAMILYTREE_MODULE_DEFINED_FAMILY_FULL
#endif

#undef ANY_GENDER
#undef SAME_GENDER
#undef DIFFERENT_GENDER

#undef FAMILY_FATHER
#undef FAMILY_MOTHER
#undef FAMILY_PROGENY
#undef FAMILY_OMMER
#undef FAMILY_INLAW
