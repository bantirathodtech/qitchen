If the current tab is not the home tab (_selectedIndex != 0),
we navigate to the home tab and return false to prevent the default back behavior.

If we're already on the home tab, we show a dialog asking the user if they want to exit the app.

to ensure that both the in-app back button and the Android back button behave consistently.

void _navigateToHomeTab(BuildContext context) {
// Find the MainScreen and set its selected index to 0 (Home)
final MainScreenState? mainScreenState =
context.findAncestorStateOfType<MainScreenState>();
if (mainScreenState != null) {
mainScreenState.onItemTapped(0);
}
}