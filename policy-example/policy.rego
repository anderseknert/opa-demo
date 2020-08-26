package policy

default allow = false

allow {
    weekend := {"Saturday", "Sunday"}
    not weekend[today]
}

today = day {
    day = time.weekday(time.now_ns())
}