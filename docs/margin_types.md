1. All Sides Margin
   margin: const EdgeInsets.all(16), // Margin on all four sides

2. Symmetric Margin
   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8); // Horizontal and vertical margin

3. Only Specific Sides Margin

   Top, Left, Right Margin
   margin: const EdgeInsets.only(top: 16, left: 16, right: 16); // Margin for top, left, and right 

   Bottom Margin
   margin: const EdgeInsets.only(bottom: 16); // Margin only at the bottom

   Left Margin
   margin: const EdgeInsets.only(left: 16); // Margin only on the left

   Right Margin
   margin: const EdgeInsets.only(right: 16); // Margin only on the right

   Top Margin
   margin: const EdgeInsets.only(top: 16); // Margin only on the top

4. From Specific Values
   margin: const EdgeInsets.fromLTRB(left, top, right, bottom); // Custom margin for each side
   margin: const EdgeInsets.fromLTRB(16, 8, 16, 0); // Left: 16, Top: 8, Right: 16, Bottom: 0
