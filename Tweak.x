#import <Foundation/Foundation.h>
#import "PXForgedditWizardViewController.h"

static UIWindow *forgedditWindow;

%hook UIImageView
%property (nonatomic, assign) BOOL __forgeddit_readonly;

- (void)setImage:(UIImage *)image {
	if (!self.__forgeddit_readonly) %orig;
}

%end

%hook UITableViewLabel
%property (nonatomic, assign) BOOL __forgeddit_readonly;

- (void)setText:(NSString *)text {
	if (!self.__forgeddit_readonly) %orig;
}

%end

%hook UserDrawerViewController

%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section == 1) ? 1 : (%orig);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != 1) {
		return %orig;
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"__forgedditCell"];
	if (!cell) {
		cell = [(UITableViewCell *)[%c(UserDrawerActionTableViewCell) alloc]
			initWithStyle:UITableViewCellStyleSubtitle
			reuseIdentifier:@"__forgedditCell"
		];
		cell.textLabel.text = @"Delete History";
		cell.imageView.image = [UIImage imageNamed:@"icon_delete_20"];
		((UITableViewLabel *)cell.textLabel).__forgeddit_readonly = YES;
		cell.imageView.__forgeddit_readonly = YES;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != 1) {
		%orig;
		return;
	}
	RedditService *service = self.accountContext.redditService;
	UINavigationController *navigationController = [[UINavigationController alloc]
		initWithRootViewController:[[PXForgedditWizardViewController alloc]
			initWithService:service
		]
	];
	[self
		presentViewController:navigationController
		animated:YES
		completion:^{
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	];
	return;
}

%end

%ctor {
	%init;
}