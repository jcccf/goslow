//
//  ScrollDiaryScreenController.m
//  goslowtest2
//
//  Created by Gregory Thomas on 11/23/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "ScrollDiaryScreenController.h"
#import "ScrollViewPageController.h"
#import "DayTableObject.h"

#import "UIImage+Colored.h"

#import "ReflectionTableManager.h"
#import "ColorReflection.h"
#import "TextReflection.h"
#import "HistoryReflectionViewController.h"
#import "PhotoReflection.h"



static NSUInteger kNumberOfPages = 0;

static int currentPage = 0;

static NSMutableArray* dates = nil;

static BOOL firstLoad = YES;

@implementation ScrollDiaryScreenController

@synthesize scrollView, dateTableView, viewControllers, tableManager, dateToPageDict,histRefViewCont, emptyDiaryImage, imagesForFilePath, activity, cameraImage;
@synthesize thisDateTable, pageControl;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

-(void)loadScrollViewWithPage:(int)page{
	if(page < 0)
		return;
	if(page >= kNumberOfPages){
		return;
	}
	
	ScrollViewPageController *s = [viewControllers objectAtIndex:page];
	
	//s should never be nil
	assert(s != nil);
	assert(s.view != nil);
	//assert(s.imageView != nil);
	[scrollView addSubview:s.view];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView1{
	if(scrollView1 == scrollView){
		CGFloat pageWidth = scrollView.frame.size.width;
		int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		if(currentPage != page){
			currentPage = page;
			//imagesForFilePath = nil;
			[activity startAnimating];
			[dateTableView reloadData];
			[activity stopAnimating];
		}
		
		[self loadScrollViewWithPage:page-1];
		[self loadScrollViewWithPage:page];
		[self loadScrollViewWithPage:page+1];
	}
}

-(void)viewDidAppear:(BOOL)animated{
	for (UIView* v in scrollView.subviews){
		[v removeFromSuperview];
	}
	//dateToPageDict = [[NSMutableDictionary alloc] init];
	//int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	//set kNumberofPages here with how many dates are in coredata etc.
	viewControllers = [[NSMutableArray alloc] init];
	tableManager = [[ReflectionTableManager alloc] init];
	[tableManager retain];
	kNumberOfPages = [tableManager.dayToTableRepDict count];
	
	// Show Empty Diary Screen when there are no reflections
	emptyDiaryImage.hidden = YES;
	if (kNumberOfPages == 0){
		emptyDiaryImage.hidden = NO;
	}
	
	NSArray* s = [[tableManager dayToTableRepDict] allKeys];
	dates = [[NSMutableArray alloc] init];
	[dates addObjectsFromArray:s];
    [dates sortUsingSelector:@selector(compare:)];
	
	//add ScrolViewPageControllers here.  The imageViews are instantiated here and added to the scrollView
	for(int i = 0; i < kNumberOfPages; i++){
		
		ScrollViewPageController *s = [[ScrollViewPageController alloc] init];
		UIView *v = [[UIView alloc] init];
		
		// Get a Random Color for a Day for a Flower
		NSString *dateKey = [dates objectAtIndex:i];
		DayTableObject *d = [tableManager.dayToTableRepDict objectForKey:dateKey];
		NSMutableArray *allref = [d reflections];
		NSMutableArray *colors = [[NSMutableArray alloc] init];
		for(Reflection *r in allref){
			if([r isKindOfClass:[ColorReflection class]])
				[colors addObject:r];
		}
		CGFloat red = 1.0f;
		CGFloat green = 1.0f;
		CGFloat blue = 1.0f;
		int j = 1;
		if ([colors count] > 0) {
			for (ColorReflection* cr in [colors reverseObjectEnumerator]) {
				// Make the colored flower
				red = [[cr colorRed] floatValue];
				green = [[cr colorGreen] floatValue];
				blue = [[cr colorBlue] floatValue];
				UIColor *myColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
				UIImage *img = [UIImage imageNamed:@"DiaryFlower.png" withColor:myColor];
				// Add the flower
				UIImageView* uiv = [[UIImageView alloc] initWithImage:img];
				double scale = 1.0;
				double offset = scrollView.frame.size.width / ([colors count]+1) * j - scrollView.frame.size.width / scale / 2;
				double voffset = 0;
				
				if ([colors count] > 3) {
					img = [UIImage imageNamed:@"DiaryFlowerStalkless.png" withColor:myColor];
					uiv = [[UIImageView alloc] initWithImage:img];
					scale = 1.0/log([colors count]/2.0);
					NSLog(@"%f",  ((scrollView.frame.size.width-0.0) * scale) / 2);
					offset = arc4random() % (int) scrollView.frame.size.width - ((scrollView.frame.size.width-0.0) * scale) / 2;
					voffset = arc4random() % (int) scrollView.frame.size.height - (scrollView.frame.size.height * scale)/2.0;
				}
				
				uiv.frame = CGRectMake(i*scrollView.frame.size.width + offset, voffset, scrollView.frame.size.width * scale, scrollView.frame.size.height * scale);
				[v addSubview:uiv];
				j++;
			}
		}
		else{
			// Default, have a white flower
			UIColor *myColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
			UIImage *img = [UIImage imageNamed:@"DiaryFlower.png" withColor:myColor];
			// Add the flower
			UIImageView* uiv = [[UIImageView alloc] initWithImage:img];
			uiv.frame = CGRectMake(i*scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
			
			[v addSubview:uiv];
		}
		
		// Add Left Arrow if needed
		if (i != 0) {
			UIImageView* leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArrowLeft.png"]];
			leftArrow.frame = CGRectMake(i*scrollView.frame.size.width+10, 80, 25, 25);
			[v addSubview:leftArrow];
		}
		
		// Add Right Arrow if needed
		if (i < kNumberOfPages-1 ) {
			UIImageView* rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArrowRight.png"]];
			rightArrow.frame = CGRectMake((i+1)*scrollView.frame.size.width-35, 80, 25, 25);
			[v addSubview:rightArrow];
		}
		s.view = v;
		[viewControllers addObject:s];
	}
	
	scrollView.pagingEnabled = YES;
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (kNumberOfPages),scrollView.frame.size.height);
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.scrollsToTop = NO;
	scrollView.delegate = self;
	scrollView.alwaysBounceHorizontal = YES;
	scrollView.clipsToBounds = YES;
	
	//only go to the most recent date if we just loaded the view otherwise, stay at the date they were on...
	if(firstLoad){
		[scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*(kNumberOfPages-1), 0)];
	}
    [self loadScrollViewWithPage:kNumberOfPages-1];
	[self loadScrollViewWithPage:kNumberOfPages-2];
	
	//CoreDataManager *c = [CoreDataManager getCoreDataManagerInstance];
	
	firstLoad = NO;
	[dateTableView reloadData];
	[activity stopAnimating];
	
	[[CoreDataManager getCoreDataManagerInstance] addLog:[NSNumber numberWithInt:2]];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//CGFloat pageWidth = scrollView.frame.size.width;
	//int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	//zactivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self viewDidAppear:NO];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)makeThisDateTable{
	thisDateTable = [[NSMutableArray alloc] init];
	if([dates count] > 0){
		NSString *dateKey = [dates objectAtIndex:currentPage];
		
		DayTableObject *d = [tableManager.dayToTableRepDict objectForKey:dateKey];
		
		NSMutableArray *allref = [d reflections];
		
		for(Reflection *r in allref){
			if(![r isKindOfClass:[ColorReflection class]]){
				[thisDateTable addObject:r];
			}
			
		}
	}
	
	
	
}

- (void)dealloc {
    [super dealloc];
}

-(UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size {
	[activity startAnimating];
	if(cameraImage == nil){
		cameraImage = [UIImage imageNamed:@"icon_digital_camera.png"];
	}
	UIGraphicsBeginImageContext(size);
	[cameraImage drawInRect:CGRectMake(0, 0, 50, 44)];
	[image drawInRect:CGRectMake(50, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	    return newImage;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	[self makeThisDateTable];
    return [thisDateTable count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	
	Reflection *r = [thisDateTable objectAtIndex:[indexPath row]];
	
	if([r isKindOfClass:[TextReflection class]]){
		TextReflection *t = (TextReflection*)r;
		NSString *text = [t reflectionText];
		if([text length] > 30){
			text = [text substringToIndex:30];
		}
		cell.textLabel.text = text;
		cell.imageView.image = nil;
		//cell.backgroundView = nil;
		
	}
	if([r isKindOfClass:[PhotoReflection class]]){
		
		if(imagesForFilePath == nil){
			imagesForFilePath = [[NSMutableDictionary alloc] init];
			
		}
		PhotoReflection *p = (PhotoReflection*)r;
		
		//file path not in dict...add it
		if([imagesForFilePath objectForKey:[p filepath]] == nil){
			
			//NSData *photoData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:[p filepath]], 0.0);
			//[activity startAnimating];
			UIImage *i = [UIImage imageWithContentsOfFile:[p filepath]];
			//UIImage *i = [self scaleImage:[UIImage imageWithContentsOfFile:[p filepath]] toSize:CGSizeMake(scrollView.frame.size.width, 44)];
			CGSize imgSize = [i size];
			
			CGRect rect = CGRectMake(imgSize.width/2, 0, imgSize.width/8, imgSize.height);
			
			CGImageRef imgRef = CGImageCreateWithImageInRect([i CGImage], rect);
			
			UIImage *im = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:UIImageOrientationRight];
			CGImageRelease(imgRef);
			
			[im retain];
			[imagesForFilePath setObject:im forKey:[p filepath]];
			//[activity stopAnimating];
			//[i release];
		}
		
		//cell.backgroundView = [[UIImageView alloc] initWithImage:[imagesForFilePath objectForKey:[p filepath]]];
		//[[cell.imageView] setFrame:CGRectMake(0, 0, 320, 44)];
		cell.imageView.image = [imagesForFilePath objectForKey:[p filepath]];
		cell.textLabel.text = @"";
	}
	
    // Configure the cell...
	//cell.textLabel.text = [NSString stringWithFormat:@"Cell number %i", [indexPath row]];
    [activity stopAnimating];
    return cell;
}

-(UITableViewCellAccessoryType)tableView:(UITableView*)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath{
		return UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	
	//TODO
	//return the correct date...
	if([dates count] > 0){
		return [dates objectAtIndex:currentPage];
	}
	else {
		return @"Empty Diary";
	}
	
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	
	Reflection *r = [thisDateTable objectAtIndex:[indexPath row]];
	
	if(histRefViewCont == nil){
		histRefViewCont = [[HistoryReflectionViewController alloc] initWithNibName:@"HistoryReflectionViewController" bundle:nil];
	}
	
	if([r isKindOfClass:[TextReflection class]]){
		TextReflection *t = (TextReflection*)r;
		histRefViewCont.navigationItem.title = [NSString stringWithFormat:@"Text for day %@", [[[t createdAt] description] substringToIndex:10]];
		histRefViewCont.t.hidden = NO;
		histRefViewCont.i.hidden = YES;
		histRefViewCont.te = [t reflectionText];
		//histRefViewCont.t.text = [r reflectionText];
		[[self navigationController] pushViewController:histRefViewCont animated:YES];
		
		
	}
	else{
		
		PhotoReflection *p = (PhotoReflection*)r;
		histRefViewCont.navigationItem.title = [NSString stringWithFormat:@"Photo for date %@",[[[p createdAt] description] substringToIndex:10]];
		histRefViewCont.t.hidden = YES;
		histRefViewCont.i.hidden = NO;
		NSLog(@"%@", [p filepath]);
		histRefViewCont.im = [UIImage imageWithContentsOfFile:[p filepath]];
		//UIImage *image = [UIImage imageWithContentsOfFile:[p filepath]];
		//assert(image != nil);
		//histRefViewCont.view = histRefViewCont.i;
		[[self navigationController] pushViewController:histRefViewCont animated:NO];
		//[image release];
	}
	
	
	
}


@end
