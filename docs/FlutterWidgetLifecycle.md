import 'package:flutter/material.dart';

void main() {
runApp(MaterialApp(
home: WidgetLifecycleDemo(),
));
}

class WidgetLifecycleDemo extends StatefulWidget {
@override
_WidgetLifecycleDemoState createState() => _WidgetLifecycleDemoState();
}

class _WidgetLifecycleDemoState extends State<WidgetLifecycleDemo> {
bool _toggleWidget = true;

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Flutter Widget Lifecycle'),
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
_toggleWidget
? ButtonBuddy(color: Colors.blue)
: Text('Widget Removed!'),
SizedBox(height: 20),
ElevatedButton(
onPressed: () {
setState(() {
_toggleWidget = !_toggleWidget;
});
},
child: Text('Toggle ButtonBuddy Widget'),
),
],
),
),
);
}
}

class ButtonBuddy extends StatefulWidget {
final Color color;

ButtonBuddy({required this.color});

@override
_ButtonBuddyState createState() => _ButtonBuddyState();
}

class _ButtonBuddyState extends State<ButtonBuddy> {
bool _isPressed = false;

// 2. initState: Initial setup and state initialization.
@override
void initState() {
super.initState();
print("ButtonBuddy initialized! Initial state: $_isPressed");
}

// 4. didUpdateWidget: Handle configuration changes from parent.
@override
void didUpdateWidget(ButtonBuddy oldWidget) {
super.didUpdateWidget(oldWidget);
if (widget.color != oldWidget.color) {
print("Color updated! New color: ${widget.color}");
}
}

// 5. didChangeDependencies: Respond to dependency changes.
@override
void didChangeDependencies() {
super.didChangeDependencies();
print("Dependencies changed, e.g., theme data or inherited widgets.");
}

// 3. build: Return the visual representation of the widget.
@override
Widget build(BuildContext context) {
return ElevatedButton(
style: ElevatedButton.styleFrom(primary: widget.color),
onPressed: () => setState(() => _isPressed = !_isPressed),
child: Text(_isPressed ? 'I\'m Pressed!' : 'Press Me!'),
);
}

// 6. deactivate: Temporarily remove the widget from the widget tree.
@override
void deactivate() {
super.deactivate();
print("ButtonBuddy deactivated! Pausing any ongoing tasks...");
}

// 7. dispose: Permanently remove the widget and clean up resources.
@override
void dispose() {
print("ButtonBuddy disposed! Releasing resources...");
super.dispose();
}
}

The Secret Life of Widgets: Unveiling the Flutter Widget Lifecycle
Authore Name
DhiWise
Last updated on Aug 20, 2024
Have you ever wondered what happens to a Flutter widget after you tap that button or scroll past
that list? It's more than just pixels dancing on the screen – there's a hidden drama unfolding, a
secret life governed by the Flutter Widget Lifecycle.

Today, we go back to the curtain and delve into the fascinating world of widget creation,
transformation, and eventual farewell, complete with a detailed code example and breakdown.

The Stages of a Flutter Widget's Journey:
A Flutter widget goes through a well-defined lifecycle, like a tiny protagonist in a grand play.
Let's follow our widget hero, "ButtonBuddy," as it navigates the stage:

1. Birth: (Declaration)
   ButtonBuddy starts its journey when it's declared in your code. Think of it as a blueprint,
   waiting to be brought to life.

class ButtonBuddy extends StatefulWidget {
@override
_ButtonBuddyState createState() => _ButtonBuddyState();
}

ButtonBuddy is declared as a stateful widget, meaning it can manage its own state.
The createState method returns a _ButtonBuddyState object, which holds the widget's state.

2. Initialization: (initState)
   When ButtonBuddy's stateful parent is built, it gets its own constructor call and enters the "
   initState" stage. Here, it sets up its internal state and prepares for the grand entrance.

class _ButtonBuddyState extends State<ButtonBuddy> {
bool _isPressed = false; // State variable for button's pressed state

@override
void initState() {
super.initState();
print("ButtonBuddy initialized! Initial state: $_isPressed");
}

initState is called once when the widget is first inserted into the widget tree.
It's used for initial setup tasks, like initializing state variables (e.g., _isPressed).

3. Build: (build)
   This is where ButtonBuddy truly materializes! The framework calls its "build" method,
   transforming the blueprint into a visual element – our shiny new button appears on the screen.

@override
Widget build(BuildContext context) {
return ElevatedButton(
onPressed: () => setState(() => _isPressed = !_isPressed),
child: Text(_isPressed ? 'I'm Pressed!' : 'Press Me!'),
);
}

build is called whenever the widget needs to be rendered (e.g., initial display, updates).
It returns the widget's visual representation (e.g., an ElevatedButton).
It can access and update state variables to dynamically change the UI.

4. DidUpdateWidget:
   If ButtonBuddy's parent changes (think of a new label or color for the button), it's notified
   through this method. It can then adapt its appearance based on the update.

@override
void didUpdateWidget(ButtonBuddy oldWidget) {
super.didUpdateWidget(oldWidget);
if (widget.color != oldWidget.color) {
print("Color updated! New color: ${widget.color}");
}
}

didUpdateWidget is called when the widget's configuration changes (e.g., parent passes new data).
It receives the old widget instance for comparison.
It's used to update state or perform actions based on configuration changes (e.g., change color).

5. DidUpdateDependencies:
   Sometimes, ButtonBuddy relies on other widgets for its existence (think of a button that changes
   based on user input). If those dependencies change, ButtonBuddy is informed here and can adjust
   accordingly.

@override
void didChangeDependencies() {
super.didChangeDependencies();
final theme = Theme.of(context);
print("Theme changed! Current theme: $theme");
}

didChangeDependencies is called after initState and whenever the widget's dependencies change (e.g.,
inherited widgets).
It's used to access dependencies that weren't available during initState.

6. Deactivate:
   When ButtonBuddy is no longer visible on the screen (perhaps the user scrolled past it), it
   enters the "deactivate" stage. It can perform cleanup tasks like pausing animations or saving
   state.

@override
void deactivate() {
super.deactivate();
print("ButtonBuddy deactivated! Pausing animations...");
}

deactivate is called when the widget is temporarily removed from the tree (e.g., scrolling).
It's used to pause animations or save state for later restoration.

7. Dispose:
   This is the final curtain call for ButtonBuddy. When it's permanently removed from the widget
   tree, the "dispose" method is called, allowing it to gracefully release any resources it holds.

@override
void dispose() {
print("ButtonBuddy disposed! Releasing resources...");
super.dispose();
}

dispose is called when the widget is permanently removed from the tree.
It's used to release resources (e.g., listeners, subscriptions).
Mastering the Widget Lifecycle:
The widget lifecycle is crucial for:

Performance Optimization: Minimize unnecessary rebuilds and optimize widget builds for smooth
animations.

Error Handling: Handle potential errors during different stages.

Resource Management: Release resources efficiently in dispose.

Building Complex Widgets: Leverage lifecycle methods for dynamic behavior.

Delving Deeper into Flutter's Essential Lifecycle Methods
While every stage of a widget's lifecycle plays a crucial role, let's focus on two frequently
encountered methods that often require careful attention: didUpdateWidget and didChangeDependencies.

Mastering didUpdateWidget: Responding to Configuration Changes
Imagine a scenario where a parent widget updates its configuration, passing new data to a child
widget. This is where didUpdateWidget steps in to help the child gracefully adapt to the change.

Here's a practical example:

class MyWidget extends StatefulWidget {
final String title;

MyWidget({required this.title});

@override
_MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
@override
void didUpdateWidget(MyWidget oldWidget) {
super.didUpdateWidget(oldWidget);
if (widget.title != oldWidget.title) {
// Handle the title change, for example, update the UI
setState(() {}); // Trigger a rebuild to reflect the new title
}
}

@override
Widget build(BuildContext context) {
return Text(widget.title);
}
}

Key Points:
didUpdateWidget receives the old widget instance as an argument, allowing for comparisons.
Use it to update state or perform actions based on configuration changes. It's not called for every
rebuild, so don't rely on it for frequent updates.
Hot Reload Quirk: During hot reload, didUpdateWidget might not be called for all widgets. To ensure
consistent behavior, consider using WidgetsBindingObserver and the didChangeAppLifecycleState method
to handle updates triggered by hot reload.
Grasping didChangeDependencies: Reacting to Dependency Changes
Widgets often depend on data from other parts of the widget tree, usually through InheritedWidgets.
didChangeDependencies is your go-to method for responding to changes in these dependencies.

Here's an example:

class

MyWidget

extends

StatefulWidget

{
@override
_MyWidgetState createState() => _MyWidgetState();
}

class

_MyWidgetState

extends

State<MyWidget> {
ThemeData _currentTheme;

@override
void didChangeDependencies() {
super.didChangeDependencies();
_currentTheme = Theme.of(context);
}

@override
Widget build(BuildContext context) {
return Text('Current theme: ${_currentTheme.primaryColor}');
}
}

Key Points:
Called after initState and whenever dependencies change.
Use it to access InheritedWidgets or other dependencies that weren't available during initState.
Avoid expensive operations here as it might be called frequently.
By understanding these two methods, you'll gain better control over how your widgets respond to
dynamic changes, leading to more responsive and adaptable Flutter applications.