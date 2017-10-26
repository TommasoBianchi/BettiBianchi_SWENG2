open util/ordering [Date]

/*
*	SIGNATURES
*/

// User related signatures

sig User {
	primaryEmail: one Email,
	emails: some Email,
	breaks: set Break,
	socialAccounts: set SocialAccount,
	//groups: set Group,
	statuses: set Status,
	preferenceList: one PreferenceList,
	defaultLocations: some DefaultLocation,
	contacts: set User,
	constraints: set Constraint,
	messagesSent: set Message,
	meetingParticipations: set MeetingParticipation
}{
	primaryEmail in emails
	this not in contacts
	//no mp1: MeetingParticipation, mp2: MeetingParticipation |
	//	mp1 in meetingParticipations and mp2 in meetingParticipations and
	//	mp1.meeting = mp2.meeting
	#(meetingParticipations.meeting) = #meetingParticipations
}

sig Email {

}{
	#(emails.this) = 1	// each email belongs to one and only one user
}

sig Break {
	defaultTime: one Date,
	duration: one Int,
	startTimeSlot: one Date,
	endTimeSlot: one Date
}{
	duration > 0
	#(breaks.this) = 1	// each break belongs to one and only one user
	DateInOrder[startTimeSlot, endTimeSlot]
	DateInOrder[defaultTime, endTimeSlot]
	DateInOrder[startTimeSlot, defaultTime]
}

sig Status {
	from: one Date,
	to: one Date
}{
	#(statuses.this) = 1	// each status belongs to one and only one user
	DateInOrder[from, to]
}

sig SocialAccount {

}{
	#(socialAccounts.this) = 1	// each socialAccount belongs to one and only one user
}

sig Group {
	members: some User
}

sig DefaultLocation {
	startingHour: one Int,
	dayOfTheWeek: one Day,
	defaultLocation: one Location
}{
	#(defaultLocations.this) = 1	// each defaultLocation belongs to one and only one user
	startingHour >= 0
}

sig Location {

}

sig MeetingParticipation {
	isAdministrator: one Bool,
	meeting: one Meeting,
	arrivingTravel: one Travel,
	leavingTravel: one Travel
}{
	#(meetingParticipations.this) = 1	// each meetingParticipation belongs to one and only one user
	arrivingTravel.arrival = meeting.location
	leavingTravel.departure = meeting.location
	leavingTravel.arrival in ((meetingParticipations.this).defaultLocations.defaultLocation + NextMeetingParticipations[this].@meeting.location)
}

// Meeting related signatures

sig Meeting {
	startDate: one Date,
	endDate: one Date,
	category: one Category,
	chat: one Chat,
	location: one Location,
	files: set File,
}{
	DateInOrder[startDate, endDate]
}

sig Message {

}{
	#(messages.this) = 1	// each message belongs to one and only one user
}

sig Chat {
	messages: set Message
}{
		#(chat.this) = 1	// each chat belongs to one and only one meeting
}

sig Category {
	superCategory: lone Category
}{
	superCategory != this
	some m: Meeting | this = m.category
}

sig File {

}{
	#(files.this) = 1	// each file belongs to one and only one meeting
}

// Travel related signatures

abstract sig TravelMean {}
one sig Walking extends TravelMean {}
one sig Driving extends TravelMean {}
one sig Biking extends TravelMean {}
one sig PublicTransportation extends TravelMean {}

sig PreferenceList {
	travelMeans: seq TravelMean
}{
	#(preferenceList.this) = 1	// each preferenceList belongs to one and only one user
	#travelMeans <= 4
}

sig Constraint {
	subject: one Subject,
	operator: one Operator,
	value: one Value,
	target: one TravelMean
}{
	#(constraints.this) = 1	// each constraint belongs to one and only one user
	operator in subject.operators
	value in subject.values
}

sig Subject {
	values: some Value,
	operators: some Operator
}

sig Operator {

}{
	#(operators.this) = 1	// each operator belongs to one and only one subject
}

sig Value {

}{
	#(values.this) = 1	// each value belongs to one and only one subject
}

sig Travel {
	steps: some TravelStep,
	travelMean: one TravelMean,
	departure: one Location,
	arrival: one Location
}{
	arrival != departure
	#((arrivingTravel + leavingTravel).this) = 1	// each travel belongs to one and only one meetingParticipation
	//#(steps.fromLocation + steps.toLocation) = #(steps) + 1
	departure in steps.fromLocation
	departure not in steps.toLocation
}

sig TravelStep {
	fromLocation: one Location,
	toLocation: one Location,
	nextStep: lone TravelStep
}{
	#(steps.this) = 1	// each travelStep belongs to one and only one travel
	fromLocation != toLocation
	#(nextStep) = 1 implies toLocation = nextStep.@fromLocation
	#(nextStep) = 1 implies steps.this = steps.nextStep
	#(nextStep) = 0 implies toLocation = steps.this.arrival//(some t: Travel | toLocation = t.arrival and this in t.steps)
	#(nextStep) = 0 implies (no ts: TravelStep | ts != this and ts in steps.this.steps and #(ts.@nextStep) = 0)
	fromLocation not in (this.^@nextStep).@toLocation
	#(@nextStep.this) <= 1
}

// Helper signatures

sig Date {
	_next: lone Date
}{ _next = this.@next }

abstract sig Day {}
one sig Monday extends Day {}
one sig Tuesday extends Day {}
one sig Wednesday extends Day {}
one sig Thursday extends Day {}
one sig Friday extends Day {}
one sig Saturday extends Day {}
one sig Sunday extends Day {}

abstract sig Bool {}
one sig True extends Bool {}
one sig False extends Bool {}

/*
*	FACTS
*/

// Each meeting as at least a participant and an administrator
fact {
	no m: Meeting | m not in MeetingParticipation.meeting
	all m: Meeting | some mp: MeetingParticipation | m = mp.meeting and mp.isAdministrator = True
}


/*
*	PREDICATES
*/

pred DateInOrder[a: Date, b: Date] {
	a not in b.^next and a != b
}

/*
*	FUNCTIONS
*/

fun NextMeetingParticipations[mp: MeetingParticipation]: set MeetingParticipation {
	{mps: meetingParticipations.mp.meetingParticipations | 
		meetingParticipations.mp.meetingParticipations.meeting.startDate in mp.meeting.endDate.^next}
}

/*
*	DEBUG STUFF
*/

fact {
	//some m: Meeting | #(MeetingParticipation.meeting & m) > 1
	#User > 0
	#Meeting > 0
	
	all t: Travel | #(t.steps) > 3
}

pred show{}

run show for 8 but 8 Int
