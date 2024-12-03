If there are 2 tabs, they should each occupy 50% of the screen width (50-50 split). If there are 3
tabs, they should also dynamically adjust to fit within the screen. If there are more than 3 tabs (
e.g., 10 tabs), they should not be squeezed into the screen. Instead, the tabs should become
horizontally scrollable, adjusting to each tab's text size, ensuring proper readability without
cramming all the tabs into the same screen width.
Dynamic width calculation for each tab based on its content length.
Tabs fill the entire screen width when there are few tabs.
Tabs become scrollable when there are too many to fit on the screen.
No tab names overlap, as each tab has its own calculated width.
The selected tab is centered when possible.
The layout is consistent whether there are 2 or 10+ tabs.