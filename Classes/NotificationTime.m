//
//  NotificationTime.m
//  goslowtest2
//
//  Created by Gregory Thomas on 10/12/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "NotificationTime.h"

@implementation NotificationTime
@synthesize datePicker, delegateReference, doneButton, dataArray, dateFormatter, dataArray2;
@synthesize morningDate, eveningDate, listOfItems, aboutView, ackView, cameraSaveView;

-(void)goToAboutText
{
	if(aboutView == nil){
		aboutView = [[AboutView alloc] initWithNibName:@"AboutView" bundle:nil];
	}
	[[self navigationController] pushViewController:aboutView animated:YES];
}

-(void)goToAckText
{
	if(ackView == nil){
		ackView = [[AckView alloc] initWithNibName:@"AckView" bundle:nil];
	}
	[[self navigationController] pushViewController:ackView animated:YES];
}

-(void)goToCameraOptions
{
	if(cameraSaveView == nil){
		cameraSaveView = [[CameraSaveController alloc] initWithNibName:@"CameraSaveController" bundle:nil];
	}
	
	[[self navigationController] pushViewController:cameraSaveView animated:YES];
	
}
-(IBAction)goToHomeScreen:(id)sender{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.datePicker.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
	self.datePicker.frame = endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.datePicker.frame.size.height;
	self.tableView.frame = newFrame;

	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	
	if([indexPath row] == 0) {
		morningDate = [datePicker date];
		[morningDate retain];
		ImprovedLog(@"Changing morning date");
		ImprovedLog(@"%@",[morningDate description]);
	}
	if([indexPath row] == 1) {
		eveningDate = [datePicker date];
		[eveningDate retain];
		ImprovedLog(@"Changing evening date");
		ImprovedLog(@"%@",[eveningDate description]);
	}
	
		// remove the "Done" button in the nav bar
	
	self.navigationItem.rightBarButtonItem = nil;
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[[CoreDataManager getCoreDataManagerInstance] setMorningEveningTime:morningDate eveningDate:eveningDate];

	[[CoreDataManager getCoreDataManagerInstance] scheduleNotifications];
	
}

	

- (IBAction)dateAction:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//Number of rows it should expect should be based on the section
	NSDictionary *dictionary = [listOfItems objectAtIndex:section];
	NSArray *array = [dictionary objectForKey:@"setup"];
	ImprovedLog(@"%d", [array count]);
	return [array count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [listOfItems count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//UITableViewCell *targetCell = [tableView cellForRowAtIndexPath:indexPath];
	
	MorningEveningTime* alarmTimes = [[CoreDataManager getCoreDataManagerInstance] fetchMorningEveningTime];
	
	NSIndexPath* morningRow = [NSIndexPath indexPathForRow:0 inSection:0];
	NSIndexPath* eveningRow = [NSIndexPath indexPathForRow:1 inSection:0];
	NSIndexPath* aboutRow = [NSIndexPath indexPathForRow:0 inSection:1];
	NSIndexPath* ackRow = [NSIndexPath indexPathForRow:1 inSection:1];
	
	
	if ([morningRow isEqual:indexPath]) {
		self.datePicker.hidden=false;
		self.datePicker.date = [alarmTimes morningDate];
	} else if([eveningRow isEqual:indexPath]) {
		self.datePicker.hidden=false;
		self.datePicker.date = [alarmTimes eveningDate];
	} else if ([aboutRow isEqual: indexPath]) {
		self.datePicker.hidden=true;
		[self goToAboutText];
	} else if ([ackRow isEqual:indexPath]){
		self.datePicker.hidden=true;
		[self goToAckText];
	}
	else {
		self.datePicker.hidden = true;
		[self goToCameraOptions];
	}

	
	
	//self.datePicker.date = [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];
	
	// check if our date picker is already on screen
	if ([morningRow isEqual:indexPath] || [eveningRow isEqual:indexPath]) {
	if (self.datePicker.superview == nil)
	{
		[self.view.window addSubview: self.datePicker];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self.datePicker.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		// we need to perform some post operations after the animation is complete
		[UIView setAnimationDelegate:self];
		
		self.datePicker.frame = pickerRect;
		
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
		self.navigationItem.rightBarButtonItem = self.doneButton;
	}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCustomCellID = @"CustomCellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCustomCellID] autorelease];
	}
	
	NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
	NSArray *array = [dictionary objectForKey:@"setup"];
	NSString *cellValue = [array objectAtIndex:indexPath.row];
	cell.textLabel.text = cellValue;
	if (indexPath.section==0) {
		cell.detailTextLabel.text = [self.dataArray2 objectAtIndex:indexPath.row];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.datePicker removeFromSuperview];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	listOfItems = [[NSMutableArray alloc] init];
	//delegateReference = [[UIApplication sharedApplication] delegate];
	self.dataArray = [NSArray arrayWithObjects:@"Morning Reminder", @"Evening Reminder", nil];
	
	self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	//self.infoButton
	MorningEveningTime* alarmTimes = [[CoreDataManager getCoreDataManagerInstance] fetchMorningEveningTime];
	
	morningDate = [alarmTimes morningDate];
	eveningDate = [alarmTimes eveningDate];
	
	[[CoreDataManager getCoreDataManagerInstance] scheduleNotifications];
	
	self.dataArray2=[NSArray arrayWithObjects:[self.dateFormatter stringFromDate:morningDate], [self.dateFormatter stringFromDate:eveningDate], nil];
	NSArray *about=[NSArray arrayWithObjects:@"About",@"Acknowledgements",nil];
	
	
	NSArray *camera = [NSArray arrayWithObjects:@"Camera Save Options", nil];
	
	NSDictionary *cameraDict = [NSDictionary dictionaryWithObject:camera forKey:@"setup"];
	//TEST
	//[[CoreDataManager getCoreDataManagerInstance] setMorningEveningTime:morningDate eveningDate:eveningDate];
	NSDictionary *timesDict = [NSDictionary dictionaryWithObject:dataArray forKey:@"setup"];
	
	NSDictionary *aboutDict = [NSDictionary dictionaryWithObject:about forKey:@"setup"];
	
	
	
	[listOfItems addObject:timesDict];
	[listOfItems addObject:aboutDict];
	[listOfItems addObject:cameraDict];
	
	ImprovedLog(@"%d", [listOfItems count]);
	
	ImprovedLog(@"%@", [about description]);
	
	ImprovedLog(@"%@", [[alarmTimes morningDate] description]);
	[datePicker setDate:morningDate];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	datePicker = nil;
	//tableview = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
