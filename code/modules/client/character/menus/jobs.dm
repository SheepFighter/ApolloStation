/datum/character/proc/JobChoicesMenu(mob/user, limit = 16, list/splitJobs = list("Chief Medical Officer"))
	var/menu_name = "job_choices_menu"

	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.

	if( !department )
		ResetJobs()

	. = "<html><body>"
	. += "<center>"

	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=edit_character_menu'>Appearence</a></b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=records_menu'>Records</a></b>"
	. += " - "
	. += "<b>Occupation</b>"
	. += " - "
	. += "<b><a href='byond://?src=\ref[user];character=switch_menu;task=antag_options_menu'>Antag Options</a></b>"
	. += "</center><hr>"

	if( !job_master )
		return

	// This is a list of job datums organized by department, also listed in order of succession
	var/list/dep_jobs = organizeJobByDepartment( jobNamesToDatums( roles ))

	. += "<table width='100%'>"
	. += "<tr>"

	. += "<td><table width='100%'>"
	. += "<tr>"
	. += "<td><b>Branch:</b></td>"
	if( !department.department_id )
		. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=change_branch'>\[[department.name]\]</a></td>"
	else
		. += "<td>[department.name]</td>"
	. += "</tr>"
	. += "</table></td>"

	if( department.department_id && user.client.character_tokens && user.client.character_tokens.len )
		. += "<td><table width='100%'>"

		for( var/type in user.client.character_tokens )
			. += "<tr>"
			. += "<td>[type] Tokens:</td>"
			. += "<td>[user.client.character_tokens[type]]</td>"
			. += "<td><a href='byond://?src=\ref[user];character=[menu_name];task=use_token;type=[type]'>Use Token</a></td>"
			. += "</tr>"

		. += "</table></td>"

	. += "</tr>"
	. += "</table>"

	. += "<table width='100%'>"
	. += "<tr>"

	for( var/datum/department/D in dep_jobs )
		if( !istype( D ))
			continue

		var/list/jobs = dep_jobs[D]

		if( !jobs || !jobs.len )
			continue

		. += "<td valign='top'>"
		. += "<table border='1' width='100%'>"
		. += "<tr bgcolor='[D.background_color]'><td colspan='2'>"
		. += "<b>[D.name]</b>"
		. += "</td></tr>"
		. += "<tr>"

		. += "<td>"
		. += "<b>Title</b>"
		. += "</td>"

		. += "<td>"
		. += "<b>Priority</b>"
		. += "</td>"

		for( var/datum/job/J in jobs )
			if( !istype( J ))
				continue

			if( !( J.title in roles )) // If its not in our roles, dont show it
				continue

			var/required_playtime = 0
			if( J.available_in_hours( user.client ))
				required_playtime = J.available_in_hours( user.client )

			var/role = J.title

			. += "<tr><td>"

			if( J.rank_succesion_level >= COMMAND_SUCCESSION_LEVEL )
				. += "<b>"

			if( J.alt_titles )
				. += "<a href='byond://?src=\ref[user];character=[menu_name];task=alt_title;job=\ref[J]'>[GetPlayerAltTitle(J)]</a>"
			else
				. += "[role]"

			if( J.rank_succesion_level >= COMMAND_SUCCESSION_LEVEL )
				. += "</b>"

			. += "</td><td>"

			if(jobban_isbanned(user, role))
				. += "<b>BANNED</b>"
			else if( required_playtime )
				. += "IN [(required_playtime)] HOURS"
			else
				. += "<a href='byond://?src=\ref[user];character=[menu_name];task=input;text=[role]'>"
				if( GetJobLevel( role ) == "High" )
					. += "<font color=blue>HIGH</font>"
				else if( GetJobLevel( role ) == "Medium" )
					. += "<font color=green>MEDIUM</font>"
				else if( GetJobLevel( role ) == "Low" )
					. += "<font color=orange>LOW</font>"
				else
					. += "<font color=red>NEVER</font>"
				. += "</a>"

			. += "</td>"
			. += "</tr>"

		. += "</table>"
		. += "</td>"

	. += "</tr>"
	. += "</table>"

	switch(alternate_option)
		if(GET_RANDOM_JOB)
			. += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=green>Get random job if preferences unavailable</font></a></u></center><br>"
		if(BE_ASSISTANT)
			. += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=red>Be assistant if preference unavailable</font></a></u></center><br>"
		if(RETURN_TO_LOBBY)
			. += "<center><br><u><a href='byond://?src=\ref[user];character=[menu_name];task=random'><font color=purple>Return to lobby if preference unavailable</font></a></u></center><br>"


	. += "<hr><center>"
	if(!IsGuestKey(user.key))
		. += "<a href='byond://?src=\ref[user];character=[menu_name];task=save'>\[Save Setup\]</a> - "
		. += "<a href='byond://?src=\ref[user];character=[menu_name];task=reset'>\[Reset Changes\]</a> - "

	. += "<a href='byond://?src=\ref[user];character=[menu_name];task=close'>\[Done\]</a>"
	. += "</center>"

	. += "</body></html>"

	user << browse(., "window=[menu_name];size=710x560;can_close=0")
	winshow( user, "[menu_name]", 1)
	return

/datum/character/proc/JobChoicesMenuDisable( mob/user )
	winshow( user, "job_choices_menu", 0)

/datum/character/proc/JobChoicesMenuProcess( mob/user, list/href_list )
	switch(href_list["task"])
		if( "save" )
			if( !saveCharacter( 1 ))
				alert( user, "Character could not be saved to the database, please contact an admin." )

		if( "reset" )
			if( !loadCharacter( name ))
				alert( user, "No savepoint to reset from. You need to save your character first before you can reset." )

		if("close")
			JobChoicesMenuDisable( user )
			user.client.prefs.ClientMenu( user )
			return

		if("change_branch")
			var/list/choices = list()
			for( var/datum/department/D in job_master.departments )
				choices[D.name] = D

			var/choice = input("Select your desired department.", "Branch Selection", null) in choices
			if( choice )
				SetDepartment( choices[choice] )
		if("use_token")
			useCharacterToken( href_list["type"], user )
			user.client.saveTokens()
		if("random")
			if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
				alternate_option += 1
			else if(alternate_option == RETURN_TO_LOBBY)
				alternate_option = 0
			else
				return 0
		if ("alt_title")
			var/datum/job/job = locate(href_list["job"])
			if (job)
				var/choices = list(job.title) + job.alt_titles
				var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
				if(choice)
					SetPlayerAltTitle(job, choice)
		if("input")
			SetJob(user, href_list["text"])

	JobChoicesMenu( user )

// This takes a list of jobs, and returns an associative list of departments with their roles tied to them
// Also organizes the departmental list in order of succession
/datum/character/proc/organizeJobByDepartment( var/list/jobs )
	var/list/departments = list()

	for( var/datum/department/D in job_master.departments )
		var/list/dep_positions = jobs & D.positions
		if( dep_positions.len )
			departments[D] = organizeJobBySuccession( dep_positions )

	return departments

// This takes a list of job datums and returns a list sorted by succession
// YES I KNOW THIS IS A BAD SORTING ALGORITHM
/datum/character/proc/organizeJobBySuccession( var/list/jobs )
	. = list()
	for( var/i = CAPTAIN_SUCCESION_LEVEL; i >= BORG_SUCCESSION_LEVEL; i-- )
		for( var/datum/job/J in jobs )
			if( J.rank_succesion_level == i )
				. += J
				jobs -= J

	return .

// This takes a list of job names, and returns a list of the associated job datums
/datum/character/proc/jobNamesToDatums( var/list/jobs )
	var/list/job_datums = list()

	for( var/datum/job/J in job_master.occupations )
		if( J.title in jobs )
			job_datums += J

	return job_datums
