package policy

default allow = false

allow {
	is_weekday
	endswith(input.email, "@eknert.com")
}

is_weekday {
	weekend := {"Saturday", "Sunday"}
	not weekend[today]
}

today = day {
	day = time.weekday(time.now_ns())
}
