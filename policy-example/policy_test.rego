package policy_test

import data.policy.allow
import data.policy.today

test_allow_right_domain_on_weekdays {
	allow with today as "Monday" with input.email as "a@eknert.com"
	allow with today as "Tuesday" with input.email as "b@eknert.com"
	allow with today as "Wednesday" with input.email as "c@eknert.com"
	allow with today as "Thursday" with input.email as "d@eknert.com"
	allow with today as "Friday" with input.email as "e@eknert.com"
}

test_deny_on_weekends {
	not allow with today as "Saturday"
	not allow with today as "Sunday"
}
