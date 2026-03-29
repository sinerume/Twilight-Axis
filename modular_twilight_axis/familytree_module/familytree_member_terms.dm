/datum/family_member/proc/GetRelationshipStyle()
	if(person)
		return person.familytree_get_parental_style()
	return "neutral"

/datum/family_member/proc/GetParentTerm()
	var/parent_style = person?.familytree_get_parental_style()
	switch(parent_style)
		if("masculine")
			return "father"
		if("feminine")
			return "mother"
	return "parent"

/datum/family_member/proc/GetChildTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "son"
		if("feminine")
			return "daughter"
	return "child"

/datum/family_member/proc/GetSpouseTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "husband"
		if("feminine")
			return "wife"
	return "spouse"

/datum/family_member/proc/GetSiblingTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "brother"
		if("feminine")
			return "sister"
	return "sibling"

/datum/family_member/proc/GetParentInLawTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "father-in-law"
		if("feminine")
			return "mother-in-law"
	return "parent-in-law"

/datum/family_member/proc/GetChildInLawTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "son-in-law"
		if("feminine")
			return "daughter-in-law"
	return "child-in-law"

/datum/family_member/proc/GetSiblingInLawTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "brother-in-law"
		if("feminine")
			return "sister-in-law"
	return "sibling-in-law"

/datum/family_member/proc/GetGrandparentTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "grandfather"
		if("feminine")
			return "grandmother"
	return "grandparent"

/datum/family_member/proc/GetGrandparentInLawTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "grandfather-in-law"
		if("feminine")
			return "grandmother-in-law"
	return "grandparent-in-law"

/datum/family_member/proc/GetGrandchildTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "grandson"
		if("feminine")
			return "granddaughter"
	return "grandchild"

/datum/family_member/proc/GetAuntUncleTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "uncle"
		if("feminine")
			return "aunt"
	return "aunt/uncle"

/datum/family_member/proc/GetNieceNephewTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "nephew"
		if("feminine")
			return "niece"
	return "niece/nephew"

/datum/family_member/proc/GetGreatGrandparentTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "great-grandfather"
		if("feminine")
			return "great-grandmother"
	return "great-grandparent"

/datum/family_member/proc/GetGreatGrandchildTerm()
	switch(GetRelationshipStyle())
		if("masculine")
			return "great-grandson"
		if("feminine")
			return "great-granddaughter"
	return "great-grandchild"
