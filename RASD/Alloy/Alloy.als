open util/ordering [Date]
open util/boolean

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
	//#(meetingParticipations.meeting) = #meetingParticipations
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
	defaultLocation: one Location,
	nextDefaultLocation: one DefaultLocation
}{
	#(defaultLocations.this) = 1	// each defaultLocation belongs to one and only one user
	#(@nextDefaultLocation.this) = 1
	(defaultLocations.this.defaultLocations -> defaultLocations.this.defaultLocations) in (^(@nextDefaultLocation))
	startingHour >= 0
	one t: Travel | t.departure = defaultLocation and t.arrival = nextDefaultLocation.@defaultLocation //a travel from subsequent locations
	LocationAfter[this, nextDefaultLocation] //QUESTO NON GARANTISCE IL GIUSTO ORDINE, BISOGNA USARE NextLocation DOPO AVERLO FIXXATO
	
}

sig Location {

}

sig MeetingParticipation {
	isAdministrator: one Bool,
	isMeetingConsistent: one Bool,
	meeting: one Meeting,
	arrivingTravel: one Travel,
	leavingTravel: one Travel,
	responseStatus: one ResponseStatus
}{
	#(meetingParticipations.this) = 1	// each meetingParticipation belongs to one and only one user
	no mp: meetingParticipations.this.meetingParticipations | mp != this and mp.@meeting = meeting	// each user participates to a meeting at most once
	arrivingTravel.arrival = meeting.location
	leavingTravel.departure = meeting.location
	leavingTravel.arrival in ((meetingParticipations.this).defaultLocations.defaultLocation + NextMeetingParticipation[this].@meeting.location)
	(leavingTravel.arrival in NextMeetingParticipation[this].@meeting.location) implies (leavingTravel = NextMeetingParticipation[this].@arrivingTravel)
	arrivingTravel.endTime = meeting.startDate
	leavingTravel.startTime = meeting.endDate
	
	////////////
	/*#(NextMeetingParticipation[this]) >= 1 implies (
	((some m: meetingParticipations.this.meetingParticipations | 
		m != this and OverlappingDates[meeting.startDate, meeting.endDate, m.@meeting.startDate, m.@meeting.endDate]) or
		//(OverlappingDates[NextMeetingParticipation[this].@arrivingTravel.startTime, NextMeetingParticipation[this]. @arrivingTravel.endTime, leavingTravel.startTime, leavingTravel.endTime]) or
		//(OverlappingDates[NextMeetingParticipation[this].@arrivingTravel.startTime, NextMeetingParticipation[this]. @arrivingTravel.endTime, meeting.startDate, meeting.endDate])) implies
		(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, NextMeetingParticipation[this].@arrivingTravel.startTime, NextMeetingParticipation[this]. @leavingTravel.endTime])) iff
			isMeetingConsistent = False)
	/////////////
	//((OverlappingDates[NextMeetingParticipation[this].@arrivingTravel.startTime, NextMeetingParticipation[this]. @arrivingTravel.endTime, leavingTravel.startTime, leavingTravel.endTime]) or
	//(OverlappingDates[NextMeetingParticipation[this].@arrivingTravel.startTime, NextMeetingParticipation[this]. @arrivingTravel.endTime, meeting.startDate, meeting.endDate])) implies
	#(NextMeetingParticipation[this]) = 0 implies (
		isMeetingConsistent = False iff (some m: meetingParticipations.this.meetingParticipations |
			this in NextMeetingParticipation[m] and OverlappingDates[m.@arrivingTravel.startTime, m.@leavingTravel.endTime, arrivingTravel.startTime, leavingTravel.endTime]) and
			#(meetingParticipations.this.meetingParticipations) > 1)		

	//	((OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, NextMeetingParticipation[this].@arrivingTravel.startTime, NextMeetingParticipation[this]. @leavingTravel.endTime]) implies
		//	(NextMeetingParticipation[this].@isMeetingConsistent = False)))*/

	isMeetingConsistent = False iff (
		some mp: (meetingParticipations.this.meetingParticipations - this) | ( 
			(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, mp.@arrivingTravel.startTime, mp.@leavingTravel.endTime] and leavingTravel != mp.@arrivingTravel and arrivingTravel != mp.@leavingTravel) or
			(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, mp.@meeting.startDate, mp.@leavingTravel.endTime] and leavingTravel = mp.@arrivingTravel and arrivingTravel != mp.@leavingTravel) or
			(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, mp.@arrivingTravel.startTime, mp.@meeting.endDate] and leavingTravel != mp.@arrivingTravel and arrivingTravel = mp.@leavingTravel)
		)
	)
}

abstract sig ResponseStatus {}
one sig Accepted extends ResponseStatus {}
one sig Declined extends ResponseStatus {}
one sig Rescheduled extends ResponseStatus {}

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
	arrival: one Location,
	startTime: one Date,
	endTime: one Date
}{
	arrival != departure
	//#((arrivingTravel + leavingTravel).this) > 0 // each travel belongs to at least one meetingParticipation
	//#(steps.fromLocation + steps.toLocation) = #(steps) + 1
	departure in steps.fromLocation
	departure not in steps.toLocation
	DateInOrder[startTime, endTime]
}

sig TravelStep {
	fromLocation: one Location,
	toLocation: one Location,
	nextStep: lone TravelStep
}{
	#(steps.this) = 1	// each  belongs to one and only one travel
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

abstract sig Day {
	nextDay: Day
}
one sig Monday extends Day {
}
one sig Tuesday extends Day {
}
one sig Wednesday extends Day {
}
one sig Thursday extends Day {
}
one sig Friday extends Day {
}
one sig Saturday extends Day {
}
one sig Sunday extends Day {
}

sig AutoDecline extends Status{}
/*
*	FACTS
*/

// Each meeting as at least a participant and an administrator
fact {
	no m: Meeting | m not in MeetingParticipation.meeting
	all m: Meeting | some mp: MeetingParticipation | m = mp.meeting and mp.isAdministrator = True
}

//Users cannot have meetings while their status is set to auto-decline. (Done)
//HO MESSO SOLO MEETING QUINDI PUO VIAGGIARE IN QUEL PERIODO, SE VOGLIAMO MODIFICARLO BASTA 
//CAMBIARE M COME MEETINGPARTECIPATION E METTERE DA DATA INIZIO VIAGGIO DI PARTENZA A DATA FINE VIAGGIO DI ARRIVO
fact {
	all u: User | all ad: statuses[u] | no m: u.meetingParticipations.meeting| 
		ad in AutoDecline and (IncludingDates[m.startDate,ad.from,ad.to] or IncludingDates[m.endDate, ad.from, ad.to])
}

//A user cannot have different default locations sharing the start time. (Done)
fact{
	all u: User | no d1,d2: u.defaultLocations | 
		d1 != d2 and d1.dayOfTheWeek = d2.dayOfTheWeek and d1.startingHour = d2.startingHour
}

fact nextDay{
	Monday.nextDay in Tuesday
	Tuesday.nextDay in Wednesday
	Wednesday.nextDay in Thursday
	Thursday.nextDay in Friday
	Friday.nextDay in Saturday
	Saturday.nextDay in Sunday
	Sunday.nextDay in Monday //ho lasciato sunday sunday. Con sunday sunday però ci mette troppo
}
// Time travel between subsequent default locations should be less than the difference between their start time.
//PER ORA HO IMPOSTO CHE CI SONO UN TRAVEL TRA TUTTE LE DEFAULT LOCATION
//fact {
//	all u: User | ( (#(u.defaultLocations)>1) implies
//		( all d1, d2: u.defaultLocations | (d1!= d2 and NextLocation[d1,d2] ) implies
//			(one t: Travel | t.departure = d1.defaultLocation and t.arrival = d2.defaultLocation)
//			)
//		)
//}

/*
*	PREDICATES
*/

pred DateInOrder[a: Date, b: Date] {
	a not in b.^next and a != b
}

pred OverlappingDates[s1: Date, e1: Date, s2: Date, e2: Date] {
	(DateInOrder[s1, s2] and DateInOrder[s2, e1]) or
	(DateInOrder[s2, s1] and DateInOrder[s1, e2]) or
	s1 = s2 or e1 = e2
}

//d1 is incuded between d2 and d3
pred IncludingDates[d1:Date, d2:Date, d3:Date]{
	DateInOrder[d2,d1] and DateInOrder[d1,d3]
}

//default location d2 is after default location d1
pred NextLocation[d1: DefaultLocation, d2: DefaultLocation]{
	LocationAfter[d1, d2]	and
	(no d3: DefaultLocation| LocationAfter[d1,d3] and LocationAfter[d3,d2])
}

//location after
pred LocationAfter[d1: DefaultLocation, d2: DefaultLocation]{
	(d1.dayOfTheWeek != d2.dayOfTheWeek and d2.dayOfTheWeek in d1.dayOfTheWeek.^nextDay) or
		(d1.dayOfTheWeek = d2.dayOfTheWeek and d1.startingHour < d2.startingHour)
}
/*
*	FUNCTIONS
*/

// computes the next meeting a user is participating to (if any)
// MI SA CHE NON SERVE PIù
	fun NextMeetingParticipation[mp: MeetingParticipation]: lone MeetingParticipation {
		{mp1: meetingParticipations.mp.meetingParticipations | 
			DateInOrder[mp.meeting.endDate, mp1.meeting.startDate] or mp.meeting.endDate = mp1.meeting.startDate}
}

/*fun NextMeetingParticipation[mp: MeetingParticipation]: lone MeetingParticipation {
	{mp1: meetingParticipations.mp.meetingParticipations | 
		DateInOrder[mp.meeting.endDate, mp1.meeting.startDate] and
			(no mp2: meetingParticipations.mp.meetingParticipations | 
				DateInOrder[mp.meeting.endDate, mp2.meeting.startDate] and DateInOrder[mp2.meeting.endDate, mp1.meeting.endDate])}
}*/

/*
*	DEBUG STUFF
*/

fact {
	//some m: Meeting | #(MeetingParticipation.meeting & m) > 1
	#User = 1
	#Meeting >1
	
	//all t: Travel | #(t.steps) > 3
	
	//#{mp: MeetingParticipation | mp.isMeetingConsistent = False} > 1
	//#{mp: MeetingParticipation | mp.isMeetingConsistent = True} > 1
	//no mp: MeetingParticipation | mp.isMeetingConsistent = False
	//some mp1: MeetingParticipation, mp2: MeetingParticipation | mp1.leavingTravel = mp2.arrivingTravel
	//#MeetingParticipation > 2
	

}

pred show{}

run show for 8 but 8 Int
