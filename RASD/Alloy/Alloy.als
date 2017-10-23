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
	defaultLocation: some DefaultLocation,
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

}

sig Break {
	defaultTime: one Date,
	duration: one Int,
	startTimeSlot: one Date,
	endTimeSlot: one Date
}{
	duration > 0
	#Break = #User.breaks
	DateInOrder[startTimeSlot, endTimeSlot]
	DateInOrder[defaultTime, endTimeSlot]
	DateInOrder[startTimeSlot, defaultTime]
}

sig Status {
	from: one Date,
	to: one Date
}{
	#Status = #User.statuses
	DateInOrder[from, to]
}

sig SocialAccount {

}{
	#SocialAccount = #User.socialAccounts
}

sig Group {
	members: some User
}

sig DefaultLocation {
	startingHour: one Int,
	dayOfTheWeek: one Day
}

sig Location {

}

sig MeetingParticipation {
	isAdministrator: one Bool,
	meeting: one Meeting
}{
	#MeetingParticipation = #User.meetingParticipations
}

// Meeting related signatures

sig Meeting {
	startDate: one Date,
	endDate: one Date,
	category: one Category,
	chat: one Chat,
	location: one Location,
	files: set File,
	arrivingTravel: one Travel,
	leavingTravel: one Travel
}{
	DateInOrder[startDate, endDate]
	arrivingTravel.arrival = location
	leavingTravel.departure = location
}

sig Message {

}{
	#Message = #Chat.messages
}

sig Chat {
	messages: set Message
}

sig Category {
	superCategory: lone Category
}{
	superCategory != this
	some m: Meeting | this = m.category
}

sig File {

}{
	#File = #Meeting.files
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
	#PreferenceList = #User
	#travelMeans <= 4
}

sig Constraint {
	subject: one Subject,
	operator: one Operator,
	value: one Value,
	target: one TravelMean
}

sig Subject {
	values: some Value,
	operators: some Operator
}

sig Operator {

}

sig Value {

}

sig Travel {
	steps: some TravelStep,
	travelMean: one TravelMean,
	departure: one Location,
	arrival: one Location
}

sig TravelStep {

}{
	#TravelStep = #Travel.steps
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

// There exists a meeting with more participants
fact {
	//some m: Meeting | #(MeetingParticipation.meeting & m) > 1
	#User = 3
	#MeetingParticipation = 6
	#Meeting = 3
}

/*
*	PREDICATES
*/

pred DateInOrder[a: Date, b: Date] {
	a not in b.^next
}

pred show{}

run show for 16
