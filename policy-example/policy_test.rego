package policy_test

import data.policy.allow
import data.policy.today

test_allow_on_weekdays {
    allow with today as "Monday"
    allow with today as "Tuesday"
    allow with today as "Wednesday"
    allow with today as "Thursday"
    allow with today as "Friday"
}

test_deny_on_weekends {
    not allow with today as "Saturday"
    not allow with today as "Sunday"
    not allow with today as "Monday"
}