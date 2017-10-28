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
}

sig Email {

}{
	#(emails.this) = 1	// each email belongs to one and only one user
}

sig Break {
	defaultTime: one Date,
	duration: one Int,
	startTimeSlot: one Date,
	endTimeSlot: one Date,
	isDoable: one Bool
}{
	#(breaks.this) = 1	// each break belongs to one and only one user
	duration > 0
	DateInOrder[startTimeSlot, endTimeSlot]
	DateInOrder[defaultTime, endTimeSlot]
	DateInOrder[startTimeSlot, defaultTime]
	 // A break is doable iff there are two consecutive "free" dates in between startTimeSlot and endTimeSlot
	isDoable = True iff (some d1: Date, d2: d1.next |
		(IncludingDates[d1, startTimeSlot, endTimeSlot] or d1 = startTimeSlot) and 
		(no mp: breaks.this.meetingParticipations | OverlappingDates[d1, d2, mp.arrivingTravel.startTime, mp.leavingTravel.endTime]))
}

abstract sig Status {
	from: one Date,
	to: one Date
}{
	#(statuses.this) = 1	// each status belongs to one and only one user
	DateInOrder[from, to]
}

sig AutoDecline extends Status {}

sig SocialAccount {}{
	#(socialAccounts.this) = 1	// each socialAccount belongs to one and only one user
}

sig Group {
	members: some User
}

abstract sig ResponseStatus {}
one sig Accepted extends ResponseStatus {}
one sig Declined extends ResponseStatus {}
one sig Rescheduled extends ResponseStatus {}

// Locations related signatures

sig DefaultLocation {
	startingHour: one Int,
	dayOfTheWeek: one Day,
	defaultLocation: one Location,
	nextDefaultLocation: one DefaultLocation,
	travelToNext: lone Travel
}{
	#(defaultLocations.this) = 1	// each defaultLocation belongs to one and only one user
	#(@nextDefaultLocation.this) = 1
	FirstLocationAfter[this, nextDefaultLocation] or (nextDefaultLocation = this)
	(defaultLocations.this.defaultLocations -> defaultLocations.this.defaultLocations) in (^(@nextDefaultLocation))
	defaultLocations.this = defaultLocations.nextDefaultLocation // the user owning this default location and the next one must be the same
	startingHour >= 0
	startingHour <= 24
	 // travel from subsequent locations
	(one t: travelToNext | t.departure = defaultLocation and t.arrival = nextDefaultLocation.@defaultLocation) or 
		(nextDefaultLocation = this and #(travelToNext) = 0)
}

sig Location {}{
	all l: Location | (some ts: TravelStep | l = ts.fromLocation or l = ts.toLocation) // there are no location that are not used by the system
}

// Meeting related signatures

abstract sig BaseMeeting {
	startDate: one Date,
	endDate: one Date,
	category: one Category,
	chat: one Chat,
	location: one Location,
	files: set File,
}

sig Meeting extends BaseMeeting {}{
	DateInOrder[startDate, endDate]
}

sig InstantMeeting extends BaseMeeting {}{
	startDate = endDate
}

sig MeetingParticipation {
	isAdministrator: one Bool,
	isMeetingConsistent: one Bool,
	meeting: one BaseMeeting,
	arrivingTravel: one Travel,
	leavingTravel: one Travel,
	responseStatus: one ResponseStatus
}{
	#(meetingParticipations.this) = 1	// each meetingParticipation belongs to one and only one user
	no mp: meetingParticipations.this.meetingParticipations | mp != this and mp.@meeting = meeting	// each user participates to a meeting at most once
	arrivingTravel.arrival = meeting.location
	leavingTravel.departure = meeting.location
	arrivingTravel.endTime = meeting.startDate
	leavingTravel.startTime = meeting.endDate
	// a leaving travel can arrive in a default location or in the location of the subsequent meeting
	leavingTravel.arrival in ((meetingParticipations.this).defaultLocations.defaultLocation + NextMeetingParticipation[this].@meeting.location)
	// if a leaving travel arrives in a meeting than the leaving travel is exactly the arriving travel of that meeting
	leavingTravel.arrival in NextMeetingParticipation[this].@meeting.location implies 
		(leavingTravel = NextMeetingParticipation[this].@arrivingTravel)
	isMeetingConsistent = False iff (
		// There is another meeting that overlaps
		some mp: (meetingParticipations.this.meetingParticipations - this) | ( 
			(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, mp.@arrivingTravel.startTime, mp.@leavingTravel.endTime] 
				and leavingTravel != mp.@arrivingTravel and arrivingTravel != mp.@leavingTravel) or
			(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, mp.@meeting.startDate, mp.@leavingTravel.endTime] 
				and leavingTravel = mp.@arrivingTravel and arrivingTravel != mp.@leavingTravel) or
			(OverlappingDates[arrivingTravel.startTime, leavingTravel.endTime, mp.@arrivingTravel.startTime, mp.@meeting.endDate] 
				and leavingTravel != mp.@arrivingTravel and arrivingTravel = mp.@leavingTravel)
		) or
		// There is a break that cannot be done
		some b: meetingParticipations.this.breaks | (
			b.isDoable = False and OverlappingDates[b.startTimeSlot, b.endTimeSlot, arrivingTravel.startTime, leavingTravel.endTime]
		)
	)
}

sig Message {}{
	#(messagesSent.this) = 1	// each message belongs to one and only one user
	#(messages.this) = 1	// each message belongs to one and only one chat
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
	some m: BaseMeeting | this = m.category // categories are not empty
}

sig File {}{
	#(files.this) = 1	// each file belongs to one and only one meeting
}

// Travel related signatures

sig Travel {
	steps: some TravelStep,
	travelMean: one TravelMean,
	departure: one Location,
	arrival: one Location,
	startTime: one Date,
	endTime: one Date
}{
	plus[plus[#(arrivingTravel.this), #(leavingTravel.this)], #(travelToNext.this)] = 1
	arrival != departure
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
	#(@nextStep.this) <= 1
	fromLocation not in (this.^@nextStep).@toLocation
	#(nextStep) = 1 implies toLocation = nextStep.@fromLocation and steps.this = steps.nextStep // if it is not the last
	#(nextStep) = 0 implies toLocation = steps.this.arrival 
		and (no ts: TravelStep | ts != this and ts in steps.this.steps and #(ts.@nextStep) = 0) // if it is the last
}

abstract sig TravelMean {}
one sig Walking extends TravelMean {}
one sig Driving extends TravelMean {}
one sig Biking extends TravelMean {}
one sig PublicTransportation extends TravelMean {}

sig PreferenceList {
	travelMeans: seq TravelMean
}{
	#(preferenceList.this) = 1	// each preferenceList belongs to one and only one user
	#travelMeans > 0
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

sig Operator {}{
	#(operators.this) = 1	// each operator belongs to one and only one subject
}

sig Value {}{
	#(values.this) = 1	// each value belongs to one and only one subject
}

// Helper signatures

sig Date {
	_next: lone Date
}{ _next = this.@next }

abstract sig Day {
	nextDay: one Day,
	distances: Day -> one Int
}

one sig Monday extends Day {}
one sig Tuesday extends Day {}
one sig Wednesday extends Day {}
one sig Thursday extends Day {}
one sig Friday extends Day {}
one sig Saturday extends Day {}
one sig Sunday extends Day {}

/*
*	FACTS
*/

// Each meeting as at least a participant and an administrator
fact oneParticipantAndAdministrator{
	no m: BaseMeeting | m not in MeetingParticipation.meeting
	all m: BaseMeeting | some mp: MeetingParticipation | m = mp.meeting and mp.isAdministrator = True
}

//Users cannot have meetings while their status is set to auto-decline. (Done)
fact autodecline{
	all u: User | all ad: statuses[u] | no m: u.meetingParticipations.meeting | 
		ad in AutoDecline and (OverlappingDates[m.startDate, m.endDate, ad.from, ad.to])
}

//A user cannot have different default locations sharing the start time. (Done)
fact noSimultaneusDefaultLocations{
	all u: User | no d1,d2: u.defaultLocations | 
		d1 != d2 and d1.dayOfTheWeek = d2.dayOfTheWeek and d1.startingHour = d2.startingHour
}

// each message of a chat belongs to a user who has accepted the invitation to the meeting of the chat
fact allMessagesFromUserInChat {
	all m: BaseMeeting | messagesSent.(m.chat.messages) in  (UserParticipations[MeetingParticipationsByStatus[Accepted]]).meeting.m
}

// each user uses only travel means in its preference list
fact travelMeansInPrefernceList{
	all u: User | u.meetingParticipations.(arrivingTravel + leavingTravel).travelMean in u.preferenceList.travelMeans[Int]
}

fact nextDay{
	Monday.nextDay in Tuesday
	Tuesday.nextDay in Wednesday
	Wednesday.nextDay in Thursday
	Thursday.nextDay in Friday
	Friday.nextDay in Saturday
	Saturday.nextDay in Sunday
	Sunday.nextDay in Monday
}

fact nextDayDistances {
	all d: Day | d.distances[d] = 0
	all d: Day | d.distances[d.nextDay] = 1
	all d: Day | d.distances[d.nextDay.nextDay] = 2
	all d: Day | d.distances[d.nextDay.nextDay.nextDay] = 3
	all d: Day | d.distances[d.nextDay.nextDay.nextDay.nextDay] = 4
	all d: Day | d.distances[d.nextDay.nextDay.nextDay.nextDay.nextDay] = 5
	all d: Day | d.distances[d.nextDay.nextDay.nextDay.nextDay.nextDay.nextDay] = 6
	//all d1: Day, d2: (Day - d1) | d1.distances[d2] = plus[1, d1.nextDay.distances[d2]]    IN OFFICIAL RASD!!
}

/*
*	PREDICATES
*/

// Date a is before Date b
pred DateInOrder[a: Date, b: Date] {
	a not in b.^next and a != b
}

// two events (s1,e1) and (s2,e2) overlaps
pred OverlappingDates[s1: Date, e1: Date, s2: Date, e2: Date] {
	(DateInOrder[s1, s2] and DateInOrder[s2, e1]) or
	(DateInOrder[s2, s1] and DateInOrder[s1, e2]) or
	s1 = s2 or e1 = e2
}

// d1 is incuded between d2 and d3
pred IncludingDates[d1:Date, d2:Date, d3:Date]{
	DateInOrder[d2,d1] and DateInOrder[d1,d3]
}

// location after
pred FirstLocationAfter[d1: DefaultLocation, d2: DefaultLocation]{
	(no d3: defaultLocations.d1.defaultLocations | 
			d1 != d3 and d2 != d3 and d1.dayOfTheWeek != d3.dayOfTheWeek and 
			d1.dayOfTheWeek.distances[d3.dayOfTheWeek] < d1.dayOfTheWeek.distances[d2.dayOfTheWeek]) and
	(d1.dayOfTheWeek = d2.dayOfTheWeek implies d1.startingHour < d2.startingHour)
}

/*
*	FUNCTIONS
*/

// returns a set of MeetingParticipations with a certain response status
fun MeetingParticipationsByStatus[rs: ResponseStatus]: set MeetingParticipation{
	{mp: MeetingParticipation | mp.responseStatus = rs}
}

// returns existing binary relationships between any User and the given MeetingParticipation
fun UserParticipations[mp: MeetingParticipation]: User -> MeetingParticipation {
	(meetingParticipations.mp -> mp) & meetingParticipations
}


// computes the next meeting a user is participating to (if any)
fun NextMeetingParticipation[mp: MeetingParticipation]: lone MeetingParticipation {
	{mp1: meetingParticipations.mp.meetingParticipations | 
		DateInOrder[mp.meeting.endDate, mp1.meeting.startDate] or mp.meeting.endDate = mp1.meeting.startDate}
}

/*
*	DEBUG STUFF
*/

fact {		// DELETE THIS
	//some m: Meeting | #(MeetingParticipation.meeting & m) > 1
	//#User > 0
	//#BaseMeeting > 2
	//some u: User | #(u.defaultLocations) > 2
	//all t: Travel | #(t.steps) > 3
	//#Break > 0
	//#{mp: MeetingParticipation | mp.isMeetingConsistent = False} > 0
	//#{mp: MeetingParticipation | mp.isMeetingConsistent = True} > 0
	//no mp: MeetingParticipation | mp.isMeetingConsistent = False
	//some mp1: MeetingParticipation, mp2: MeetingParticipation | mp1.leavingTravel = mp2.arrivingTravel
	//#MeetingParticipation > 2
	//#Break > 2
	//#(DefaultLocation) > 3
	//some u: User | #(u.defaultLocations) = 1
	//some d1,d2: DefaultLocation | d1.dayOfTheWeek = d2.dayOfTheWeek and d1 != d2
	//some b: Break | b.isDoable = False
	//some b: Break | b.isDoable = True
	//#(AutoDecline) > 0
	//#Message > 3
	//#Chat > 2
	//#(InstantMeeting) > 0
	//#(Meeting) > 0
	//#Travel > 2
}		// DELETE THIS

/*
*	ASSERTIONS
*/

// if there is a message in a meeting, then there is also a user with the accepted status
assert messageInMeetingEntailsAcceptedParticipation {
	all m: Meeting | 
		#(m.chat.messages) > 0 implies (some mp: MeetingParticipation | mp.meeting = m and mp.responseStatus = Accepted)
}

// the arriving and leaving travel of a meetingParticipation are never equal
assert arrivingAndLeavingTravelAreDifferent {
	no mp: MeetingParticipation | mp.arrivingTravel = mp.leavingTravel
}

// the presence of a single non consistent meeting implies that is has been made inconstistent by the presence of a non doable break
assert singleInconsistentMeetingEntailsNotDoableBreak {
	#{mp: MeetingParticipation | mp.isMeetingConsistent = False} = 1 implies #{b: Break | b.isDoable = False} > 0
}

/*
*  PREDICATE TO SHOW
*/

pred show{}		// DELETE THIS

pred showUser {
	#User > 1
	#Break > 1
	#Status > 1
	#SocialAccount > 1
	#Group > 1
	#contacts > 1
	#Constraint > 1
	#MeetingParticipation = 0
}

pred showMeeting {
	#BaseMeeting = 1
	#Meeting = 1
	#MeetingParticipation > 2
	#Message > 4
	#File > 2
	some mp : MeetingParticipation | mp.responseStatus = Accepted
	some mp : MeetingParticipation | mp.responseStatus = Rescheduled
	some mp : MeetingParticipation | mp.responseStatus = Declined
}

pred showChat {
	some m: Meeting | #(messagesSent.(m.chat.messages)) > 1
}

pred showTravel {
	#{t: Travel | #(t.steps) > 1} = 1
	some t: Travel | #(t.steps) > 4
}

run show for 8 but 8 Int		// DELETE THIS

run showUser for 8 but 8 Int

run showMeeting for 8 but 8 Int

run showChat for 8 but 8 Int

run showTravel for 8 but 8 Int

check messageInMeetingEntailsAcceptedParticipation for 8 but 8 Int

check arrivingAndLeavingTravelAreDifferent for 8 but 8 Int

check singleInconsistentMeetingEntailsNotDoableBreak for 8 but 8 Int
